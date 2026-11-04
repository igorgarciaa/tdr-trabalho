## Funções do pipeline. Os pacotes (readr, dplyr, tidyr, purrr, ggplot2)
## são carregados pelo tar_option_set() do _targets.R.

## Ordem do calendário para o fator do mês.
meses_ordem <- c(
  "jan", "fev", "mar", "abr", "mai", "jun",
  "jul", "ago", "set", "out", "nov", "dez"
)

## Leitura ---------------------------------------------------------------

## Cadastro: separador ";", codificação Latin-1 (ISO-8859-1).
ler_cadastro <- function(arquivo) {
  read_delim(
    arquivo,
    delim = ";",
    locale = locale(decimal_mark = ",", encoding = "latin1"),
    col_types = cols(
      codigo = col_character(),
      nome = col_character(),
      distrito = col_character(),
      equipes = col_double()
    )
  )
}

## Arquivo anual: separador ";", texto ASCII, mês sem registro como "-".
ler_anual <- function(arquivo) {
  read_delim(
    arquivo,
    delim = ";",
    locale = locale(decimal_mark = ",", encoding = "UTF-8"),
    na = "-",
    col_types = cols(codigo = col_character(), .default = col_double())
  )
}

## Os três anos empilhados; o ano vem do nome do arquivo.
ler_anos <- function(arquivos) {
  arquivos |>
    set_names(basename(arquivos)) |>
    map(ler_anual) |>
    list_rbind(names_to = "arquivo") |>
    mutate(ano = as.integer(parse_number(arquivo)), .after = codigo) |>
    select(-arquivo)
}

## Arrumação -------------------------------------------------------------

## DECISÃO sobre os meses sem registro: um mês sem registro é um mês em
## que a consulta não foi registrada, e não um mês sem consultas. O NA é
## mantido: os totais somam só os meses registrados e as médias usam só
## esses meses (na.rm = TRUE).

## Forma longa, mês na ordem do calendário, junção ao cadastro e
## consultas por equipe. A junção mantém todas as linhas da tabela longa.
arrumar <- function(anos, cadastro) {
  longa <- anos |>
    pivot_longer(
      cols = -c(codigo, ano),
      names_to = "mes",
      values_to = "consultas"
    ) |>
    mutate(mes = factor(mes, levels = meses_ordem))
  juntada <- longa |>
    left_join(cadastro, by = "codigo", relationship = "many-to-one") |>
    mutate(consultas_equipe = consultas / equipes)
  ## Conferências: a junção não muda o número de linhas, todo mês virou
  ## nível do fator e toda unidade medida está no cadastro.
  stopifnot(
    nrow(juntada) == nrow(longa),
    !anyNA(juntada$mes),
    !anyNA(juntada$distrito)
  )
  juntada
}

## Unidade do cadastro sem medição alguma (junção filtrante).
unidade_sem_medicao <- function(cadastro, anos) {
  anti_join(cadastro, anos, by = "codigo")
}

## Conferência com o LEIA-ME: linhas, ausentes e soma por ano.
conferir <- function(dados) {
  dados |>
    summarise(
      linhas = n(),
      ausentes = sum(is.na(consultas)),
      soma = sum(consultas, na.rm = TRUE),
      .by = ano
    )
}

## Resumos ---------------------------------------------------------------

resumo_unidade <- function(dados) {
  dados |>
    summarise(
      meses = sum(!is.na(consultas)),
      total = sum(consultas, na.rm = TRUE),
      media_equipe = mean(consultas_equipe, na.rm = TRUE),
      .by = c(codigo, nome, distrito)
    ) |>
    arrange(desc(media_equipe))
}

resumo_distrito <- function(dados) {
  dados |>
    summarise(
      unidades = n_distinct(codigo),
      total = sum(consultas, na.rm = TRUE),
      media_equipe = mean(consultas_equipe, na.rm = TRUE),
      .by = distrito
    ) |>
    arrange(desc(media_equipe))
}

## Tabela de apresentação: uma linha por distrito, uma coluna por ano.
tabela_distrito_ano <- function(dados) {
  dados |>
    summarise(total = sum(consultas, na.rm = TRUE), .by = c(distrito, ano)) |>
    arrange(ano) |>
    pivot_wider(names_from = ano, values_from = total) |>
    arrange(distrito)
}

## Um resumo por ano, para a pergunta da variação 2023-2025.
resumo_ano <- function(dados) {
  dados |>
    summarise(
      meses = sum(!is.na(consultas)),
      total = sum(consultas, na.rm = TRUE),
      media_equipe = mean(consultas_equipe, na.rm = TRUE),
      .by = ano
    )
}

## Média de consultas por equipe em cada ano e mês (sazonalidade).
media_mensal <- function(dados) {
  dados |>
    summarise(
      media = mean(consultas_equipe, na.rm = TRUE),
      .by = c(ano, mes)
    ) |>
    arrange(ano, mes)
}

## Média por mês nos três anos juntos (mês de maior e de menor média).
media_por_mes <- function(dados) {
  dados |>
    summarise(media = mean(consultas_equipe, na.rm = TRUE), .by = mes) |>
    arrange(mes)
}

## Figuras ---------------------------------------------------------------

grafico_sazonal <- function(medias) {
  ggplot(medias, aes(x = mes, y = media, colour = factor(ano))) +
    geom_line(aes(group = ano)) +
    geom_point() +
    labs(
      x = "Mês",
      y = "Consultas por equipe (média)",
      colour = "Ano"
    ) +
    theme_minimal()
}

grafico_distritos <- function(dados) {
  dados |>
    filter(!is.na(consultas_equipe)) |>
    ggplot(aes(x = distrito, y = consultas_equipe)) +
    geom_boxplot() +
    labs(x = "Distrito", y = "Consultas por equipe no mês") +
    theme_minimal()
}

ajustar_modelo <- function(dados) {
  lm(
    log(consultas_equipe) ~ ano + mes + distrito,
    data = filter(dados, consultas_equipe > 0)
  )
}
