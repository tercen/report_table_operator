library(tercen)
library(dplyr)
library(knitr)

ctx = tercenCtx()

mat <- ctx$as.matrix()
cnames <- ctx$cselect() %>%
  tidyr::unite(col = "col_names", sep = "_")
colnames(mat) <- cnames$col_names

rows <- ctx$rselect()
df <- cbind(rows, mat) %>% 
  as_tibble()

if (ncol(df) > 50 || nrow(df) > 100) {
  stop("Error: Data frame exceeds 50 columns or 100 rows.")
}
  
markdown_table <- knitr::kable(df, format = "markdown", digits = 3, align = "c")
tmp_file <- tempfile(fileext = ".md")
cat(markdown_table, sep = "\n", file = tmp_file)
on.exit(unlink(tmp_file))

tercen::file_to_tercen(tmp_file, filename = "Report_Table.md") %>%
  mutate(mimetype = "text/markdown") %>%
  ctx$addNamespace() %>%
  as_relation() %>%
  as_join_operator(list(), list()) %>%
  save_relation(ctx)
