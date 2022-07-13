# cluster_abandono
Análise de clusterização com dados educacionais utilizando algoritmo k-means para prover suporte complementar à predição do abandono escolar.


<h3>Introdução</h3>

O presente estudo foi desenvolvido durante a execução do projeto do “Estudos Educacionais”, vinculado ao <a href="http://www.ijsn.es.gov.br/">Instituto Jones dos Santos Neves (IJSN/ES)</a> em parceria com a Secretaria de Estado de Educação do Espírito Santo. A análise funciona como suporte adicional às análise de predição do abandono escolar dos alunos da rede estadual de ensino, com a finalidade de identificar características compartilhadas entre os indivíduos que compõem diferentes grupos de alunos. Nesse sentido, o estudo buscou trazer <i>insights</i> acerca da forma como as características desses alunos são agrupadas e, mais especificamente, quais são as características de perfis dos alunos em situação de abandono. O objetivo final do projeto é contribuir para a tomada de decisões na focalização de políticas públicas educacionais. 
A pesquisa em questão foi financiada pela <a href="http://fapes.es.gov.br/">Fundação de Amparo à Pesquisa e Inovação do Espírito Santo (FAPES)</a>.

<h3>Método</h3>

Para realização da análise de cluster foi utilizado o método K-means (ou K-médias), que consiste em um método de aprendizado não supervisionado, que objetiva particionar os dados em um número K de agrupamentos não sobrepostos. Para realização deste método é necessária a especificação do número de clusters desejado, para que o algoritmo possa designar cada observação a um cluster específico. Foi utilizado o algoritmo Hartigan and Wong (1979), parâmetro default da função <i>kmeans()</i>, desenvolvida em linguagem R.
Para a determinação do número ideal de clusters foram utilizados três métodos gráficos distintos, a saber: o método wws (<i>“within sum of squares”</i>), baseado na soma dos quadrados intracluster; o método da silhueta média ou <i>“average silhouette”</i>; e o método <i>“gap statistics”</i>.
Considerando o grande número de variáveis de interesse dos alunos disponíveis para a análise, foram realizados testes de performance a partir do método de Análise de Componentes Principais (PCA) visando a redução da dimensionalidade dos dados.

<h3>Etapas do Estudo</h3>

<h4>Tratamento de dados</h4>

As informações utilizadas para a análise consistem em variáveis extraídas do banco unificado de informações educacionais dos alunos, que contém informações disponíveis em cinco fontes distintas, sendo elas: o banco do Sistema Estadual de Gestão Escolar (SEGES), que contém dados de notas, faltas e dias letivos; o de Situação dos alunos (SEDU), que contém informações sobre o rendimento escolar; e os bancos de Matrículas, Escolas e Docentes (Censo Escolar/INEP), que condensam características dos estudantes, das escolas e dos docentes da rede estadual. O banco unificado foi previamente limpo e tratado.

Primeiramente, foram filtrados apenas os alunos do Ensino Médio Regular, excluindo-se alunos de outras modalidades de ensino e alunos falecidos. Posteriormente, foram selecionadas as variáveis e interesse dentre as disponíveis, sendo elas as relacionadas ao sexo, idade, raça/cor, existência de necessidades especiais, turno de ensino, rendimento, notas, proporção de faltas e notas das turmas.

Para a performance do K-means é necessário utilizar apenas variáveis numéricas, que devem estar em uma escala uniforme. No caso das variáveis de escalas diferentes, é preciso escalá-las para média 0 e desvio padrão 1, e os valores ausentes (NA) devem ser omitidos ou imputados no banco de dados. Para o presente estudo, optou-se pela exclusão das observações com registros ausentes com o uso do comando <i>na.omit()</i>.

Para o tratamento das variáveis selecionadas, as mesmas foram divididas entre variáveis contínuas e categóricas. As variáveis contínuas foram escaladas utilizando a função <i>scale()</i>. No caso das variáveis categóricas, visando a padronização dos valores numéricos, cada categoria de uma variável foi transformada em uma nova variável <i>dummy</i>, o conjunto destas substituindo a original. Após os tratamentos distinto das variáveis continuas e categóricas, a base foi reunida utilizando a função <i>cbind()</i>. No processo de tratamento dos dados perderam-se aproximadamente 10.000 observações, restando cerca de 88.000 alunos no banco de dados do Ensino Médio (EM) para a realização da análise.

É relevante pontuar que a análise descritiva dos dados indicou que em casos específicos algumas variáveis continham apenas valores iguais a 0, o que impediria a continuidade do procedimento de cálculo dos clusters. Em tais casos, as variáveis em questão foram suprimidas do banco de dados. No caso das análises relativas ao ano de 2020, não houveram alunos em nenhuma das séries em situação de “reprovado”, devido a um direcionamento do governo do estado em virtude da pandemia da Covid-19, por essa razão, a variável foi suprimida da análise.

<h4>Redução de Dimensionalidade</h4>

Devido ao grande número de variáveis disponíveis, decidiu-se por viabilizar a redução da dimensão dos dados, por meio da redução de diferentes técnicas para redução do número de variáveis utilizadas para os cálculos. Uma das operações realizadas foi a análise de correlações entre as variáveis, onde foram analisadas variáveis de faltas e de notas dos alunos. Os testes de correlação efetuados indicaram correlação acima de 60% entre as variáveis de notas de todas as disciplinas curriculares com as notas das disciplinas de língua portuguesa ou matemática. Optou-se, a partir da análise, pela supressão dos dados das demais disciplinas.

Outro procedimento testado foram testes do uso da análise de cluster em associação ao método de análise de componentes principais (PCA). A análise de componentes principais consiste em uma técnica da estatística multivariada, que transforma o conjunto de variáveis iniciais em outro conjunto de variáveis linearmente não correlacionadas denominadas componentes principais. Para os testes com componentes principais foram utilizadas as funções <i>pca()</i> e <i>prcomp()</i>. Contudo, os testes realizados indicaram pouca contribuição da análise de PCA para a performance do algoritmo, de modo que foi preferida a utilização das variáveis originais em prol de resultados mais completos, ainda que ocorram alguma perda de precisão nos resultados.

<h4>Determinação do número ideal de Clusters</h4>

Para a determinação do número ideal de clusters optou-se pela utilização da função <i>factoextra::fviz_nbclust()</i>, a fim de obter os resultados para os três métodos selecionados: <i>wss</i>, <i>silhouette</i> e <i>gap_stat</i>.

Os três métodos foram avaliados em paralelo a fim de confirmar os números ótimos de agrupamentos nos dados. Nos casos em que houve divergência no número ideal de clusters obtido a partir da interpretação dos resultados gráficos dos três métodos, foram realizados testes com distintos números de clusters a fim de avaliar a melhor adequação dos resultados de agrupamentos dos dados. 

Para a identificação dos melhores resultados, foram comparadas as médias das variáveis originais obtidas em cada cluster para os diferentes números de clusters testados, compreendendo que para a validação da adição de novos clusters, esta deve resultar em diferenças expressivas das médias das variáveis quando comparadas às dos resultados obtidos previamente com um cluster a menos.

<h4>K-means</h4>

A fim de possibilitar a reprodução dos resultados obtidos pelo algoritmo, é preciso estabelecer um parâmetro fixo para o gerador de números pseudo-aleatórios, a partir da função <i>set.seed()</i>. Para a realização das análises, os <i>inputs</i> e parâmetros ajustados na função do <i>k-means</i> são: os dados numéricos escalados e tratados, o número de clusters desejado, e os parâmetros de número de inicializações do algoritmo e o máximo de iterações. 

No caso do estudo, as funções foram rodadas utilizando os números de cluster obtidos através dos métodos wss, silhouette, e gap_stat, a fim de avaliar a adequação dos diferentes resultados.

Após a realização de todos os testes previamente descritos, as configurações finais dos parâmetros da função <i>kmeans()</i> ficaram em <i>nstart=25</i>, <i>iter.max=200</i>. Os resultados para os diferentes clusters foram salvos em .csv e analisados a partir de painéis em software PowerBI.


