#'Análise de clusterização - K-means - 3ª série do EM com PCA
#'Etapa: Testes com componentes principais
#'Projeto: Estudos Educacionais/Preditor do Abandono
#'Elaboração: Clara Crizio
#'------------------------------------------------------------

library(tidyverse)
library(Hmisc)
library(cluster)
library(factoextra)
library(data.table)

#'Carregando o banco de dados unificado:

seges_em_2020 <- readRDS("/dados")

#'Filtrando apenas ensino regular e alunos vivos, 
#'Alterando tipo de dado e selecionando as variáveis de interesse para a análise:
#'Obs.1: Usando apenas variáveis dos primeiros trimestres (faltas e notas).
#'Obs.2: Em 2020 ninguém foi reprovado, por isso a variável foi suprimida da análise.

seges_em_2020 <- seges_em_2020 %>% 
  filter(MATRICULA_IN_REGULAR=="1", SITUACAO_CO_SITUACAO!="5",  SEGES_ID_ETAPA_MATRICULA=="18") %>% 
  select(SITUACAO_CO_SITUACAO, DIS, MATRICULA_TP_SEXO, SEGES_IDADE, SEGES_ID_TURNO,
         MATRICULA_TP_COR_RACA, MATRICULA_IN_NECESSIDADE_ESPECIAL,
         SEGES_qt_escolas, SEGES_qt_turma, SEGES_qt_turno, 
         SEGES_lp_1_tri, SEGES_mat_1_tri,
         SEGES_PROP_FALTA_MT, SEGES_PROP_FALTA_PT,
         SEGES_NOTA_TURMA_TRI1PT, SEGES_NOTA_TURMA_TRI1MT
  ) %>% 
  mutate(SITUACAO_CO_SITUACAO_SIR=(ifelse(SITUACAO_CO_SITUACAO=="1", 1, 0)), 
         SITUACAO_CO_SITUACAO_ABANDONO=(ifelse(SITUACAO_CO_SITUACAO=="2", 1, 0)),
         SITUACAO_CO_SITUACAO_REPROVADO=(ifelse(SITUACAO_CO_SITUACAO=="3", 1, 0)),
         SITUACAO_CO_SITUACAO_APROVADO=(ifelse(SITUACAO_CO_SITUACAO=="4", 1, 0)),
         MATRICULA_TP_SEXO_MASC=(ifelse(MATRICULA_TP_SEXO=="1", 1, 0)),
         MATRICULA_TP_SEXO_FEM=(ifelse(MATRICULA_TP_SEXO=="2", 1, 0)),
         MATRICULA_TP_COR_RACA_ND=(ifelse(MATRICULA_TP_COR_RACA=="0", 1, 0)),
         MATRICULA_TP_COR_RACA_BRANCA=(ifelse(MATRICULA_TP_COR_RACA=="1", 1, 0)),
         MATRICULA_TP_COR_RACA_PRETA=(ifelse(MATRICULA_TP_COR_RACA=="2", 1, 0)),
         MATRICULA_TP_COR_RACA_PARDA=(ifelse(MATRICULA_TP_COR_RACA=="3", 1, 0)),
         MATRICULA_TP_COR_RACA_AMARELA=(ifelse(MATRICULA_TP_COR_RACA=="4", 1, 0)),
         MATRICULA_TP_COR_RACA_INDIG=(ifelse(MATRICULA_TP_COR_RACA=="5", 1, 0)),
         SEGES_ID_TURNO_MANHA=(ifelse(SEGES_ID_TURNO=="1", 1, 0)),
         SEGES_ID_TURNO_TARDE=(ifelse(SEGES_ID_TURNO=="2", 1, 0)),
         SEGES_ID_TURNO_NOITE=(ifelse(SEGES_ID_TURNO=="3", 1, 0)),
         SEGES_ID_TURNO_TI=(ifelse(SEGES_ID_TURNO=="4", 1, 0))
  ) %>% 
  ungroup() %>% 
  select(-MATRICULA_TP_SEXO, -MATRICULA_TP_COR_RACA, -SITUACAO_CO_SITUACAO, -SEGES_ID_TURNO, -SEGES_ID_TURNO_NOITE,
         -SITUACAO_CO_SITUACAO_REPROVADO) %>% 
  na.omit()

#'Separando variáveis categóricas das variáveis contínuas:

seges_em_2020_cont <- seges_em_2020 %>% 
  select(SEGES_IDADE, SEGES_qt_escolas, SEGES_qt_turma, SEGES_qt_turno,
         SEGES_lp_1_tri, SEGES_mat_1_tri,
         SEGES_NOTA_TURMA_TRI1PT, SEGES_NOTA_TURMA_TRI1MT)

seges_em_2020_categ <- seges_em_2020 %>%
  select(-names(seges_em_2020_cont)) %>% 
  ungroup() %>% 
  select(-SITUACAO_CO_ALUNO)

#'Escalando as variáveis contínuas:

seges_em_2020_scaled <- seges_em_2020_cont %>% scale()

#'Reunindo as variáveis categóricas e contínuas:

seges_em_2020_kmeans <- cbind(as.data.table(seges_em_2020_scaled), seges_em_2020_categ)

rm(seges_em_2020_categ, seges_em_2020_cont, seges_em_2020_scaled)

#'Análise de Componentes Principais:
#'Função prcomp()

pca.out <- prcomp(seges_em_2020_kmeans)
plot(pca.out)
plot((pca.out), type='l')

summary(pca.out) # 4 componentes principais

comp.princ <- data.frame(pca.out$x[,1:4])

#'K-means com 4 componentes principais:

set.seed(123)

#'Definindo número ideal de clusters com pacote factoextra: método wss

fviz_nbclust(comp.princ, kmeans, method = "wss", nstart=25, iter.max = 200) # 5 ou 6 clusters

#'Número ideal de clusters: método average silhouette

fviz_nbclust(comp.princ, kmeans, method = "silhouette", nstart=25, iter.max = 200) # 2 clusters

#'Número ideal de clusters: método gap stat

fviz_nbclust(comp.princ, kmeans, method = "gap_stat", nstart=25, iter.max = 200) # 4 clusters

#'-----------------------

#'K-means com 4 clusters:

km.out.4=kmeans(comp.princ, 4, nstart=25, iter.max = 200)

#'Plotando gráfico com clusters atribuídos pelo k-means:

fviz_cluster(km.out.4, data = comp.princ,
             geom = "point",
             main = "K-Means: Alunos do Ensino Médio (2020)", 
             ellipse.type = "convex", 
             ggtheme = theme_bw())

#'Médias das variáveis para cada cluster:

aggregate(seges_em_2020, by=list(cluster=km.out.4$cluster), mean)

#'Total de indivíduos por cluster:

km.out.4$size

#------------------------

#'K-means com 5 clusters:

km.out.5=kmeans(comp.princ, 5, nstart=25, iter.max = 200)

#'Plotando gráfico com clusters atribuídos pelo k-means:

fviz_cluster(km.out.5, data = comp.princ,
             geom = "point",
             main = "K-Means: Alunos do Ensino Médio (2020)", 
             ellipse.type = "convex", 
             ggtheme = theme_bw())

#'Médias das variáveis para cada cluster:

aggregate(seges_em_2020, by=list(cluster=km.out.5$cluster), mean)

#'Total de indivíduos por cluster:

km.out.5$size

#------------------------

#'K-means com 6 clusters:

km.out.6=kmeans(comp.princ, 6, nstart=25, iter.max = 200)

#'Plotando gráfico com clusters atribuídos pelo k-means:

fviz_cluster(km.out.6, data = comp.princ,
             geom = "point",
             main = "K-Means: Alunos do Ensino Médio (2020)", 
             ellipse.type = "convex", 
             ggtheme = theme_bw())

#'Médias das variáveis para cada cluster:

aggregate(seges_em_2020, by=list(cluster=km.out.6$cluster), mean)

#'Total de indivíduos por cluster:

km.out.6$size

#'Unindo colunas de cluster com dados originais:

seges_em_2020_result <- seges_em_2020 %>%
  cbind(cluster_6=km.out.6$cluster, cluster_5=km.out.5$cluster, cluster_4=km.out.4$cluster)

#'Salvando resultados em csv para análise em painel no powerBI:

write.csv(seges_em_2020_result, "Resultados_ClustersPCA.csv")
