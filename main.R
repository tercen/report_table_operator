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


## Write CSV File
tmp_file1 <- tempfile(fileext = ".csv")
on.exit(unlink(tmp_file1))

write.csv(df, file = tmp_file1, quote = FALSE, row.names = FALSE)
df_1 <- tercen::file_to_tercen(tmp_file1, filename = "Report_Table.csv")
  
## Write markdown preview

df_sub <- df %>%
  slice_head(n = 30) %>%
  select(1:min(ncol(.), 10))
markdown_table <- knitr::kable(df_sub, format = "markdown", digits = 3, align = "c")
tmp_file <- tempfile(fileext = ".md")
cat("Preview (first 10 columns and 30 rows)\nThe full Table can be downloaded below.\n", markdown_table, sep = "\n", file = tmp_file)
on.exit(unlink(tmp_file))

tercen::file_to_tercen(tmp_file, filename = "Report_Table.md") %>%
  mutate(mimetype = "text/markdown") %>%
  bind_rows(df_1) %>%
  ctx$addNamespace() %>%
  as_relation() %>%
  as_join_operator(list(), list()) %>%
  save_relation(ctx)
