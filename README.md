# tdr-trabalho

Projeto reprodutível do trabalho intermediário de Tecnologia de Dados
(UFPR): análise dos dados simulados de consultas nas unidades básicas de
saúde de um município, de 2023 a 2025, sorteados para o login
`igorgarciaa`. O pipeline lê os dados, arruma a tabela, confere com o
`LEIA-ME.txt`, calcula os resumos e as figuras e renderiza o relatório.

## Como reproduzir

Precisa estar instalado antes: R (versão registrada no `renv.lock`),
Quarto e Git. No Linux, também as bibliotecas do sistema que
`renv::sysreqs()` listar.

```bash
git clone https://github.com/igorgarciaa/tdr-trabalho.git
cd tdr-trabalho
```

No R, aberto na raiz do projeto, dois comandos:

```r
renv::restore()
targets::tar_make()
```

O relatório sai em `relatorio.html`.

## Arquivos

| Arquivo | Conteúdo |
| --- | --- |
| `dados/` | Os cinco arquivos da Lista 03, sem alteração |
| `R/funcoes.R` | Funções de leitura, arrumação, conferência, resumos e figuras |
| `_targets.R` | Definição do pipeline |
| `relatorio.qmd` | Relatório, que só lê alvos do pipeline |
| `_dependencies.R` | Declara o pacote `quarto` para o `renv` |
| `renv.lock`, `.Rprofile`, `renv/` | Ambiente de pacotes do projeto |
| `.github/workflows/relatorio.yaml` | Integração contínua: roda o pipeline e guarda o relatório |
| `.lintr` | Estilo do projeto |

## Uso de LLMs

- Ferramenta: [Claude, Opus 5.5].
- Partes em que foi usada: checklist das etapas, rascunho das funções, do relatório e do workflow. 
Utilizado também para solucionar erros durante a construção do trabalho e que levaria mais tempo do que o disponível.
- Como o resultado foi conferido: a conferência
  do pipeline reproduz as linhas, os meses sem registro e as somas do
  `LEIA-ME.txt`;