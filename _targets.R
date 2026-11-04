library(targets)
library(tarchetypes)

tar_option_set(
  packages = c("readr", "dplyr", "tidyr", "purrr", "ggplot2")
)

tar_source("R")

list(
  ## Arquivos de dados como alvos de arquivo
  tar_target(arq_cadastro, "dados/cadastro.csv", format = "file"),
  tar_target(arq_2023, "dados/consultas_2023.csv", format = "file"),
  tar_target(arq_2024, "dados/consultas_2024.csv", format = "file"),
  tar_target(arq_2025, "dados/consultas_2025.csv", format = "file"),
  
  ## Leitura
  tar_target(cadastro, ler_cadastro(arq_cadastro)),
  tar_target(anos, ler_anos(c(arq_2023, arq_2024, arq_2025))),
  
  ## Tabela arrumada e conferência
  tar_target(dados, arrumar(anos, cadastro)),
  tar_target(sem_medicao, unidade_sem_medicao(cadastro, anos)),
  tar_target(conferencia, conferir(dados)),
  
  ## Resumos
  tar_target(por_unidade, resumo_unidade(dados)),
  tar_target(por_distrito, resumo_distrito(dados)),
  tar_target(distrito_ano, tabela_distrito_ano(dados)),
  tar_target(por_ano, resumo_ano(dados)),
  tar_target(sazonal, media_mensal(dados)),
  tar_target(por_mes, media_por_mes(dados)),
  
  ## Figuras
  tar_target(fig_sazonal, grafico_sazonal(sazonal)),
  tar_target(fig_distritos, grafico_distritos(dados)),
  
  tar_target(modelo, ajustar_modelo(dados)),
  
  tar_quarto(relatorio, "relatorio.qmd")
)
