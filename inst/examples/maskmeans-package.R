
## Simulate data
set.seed(12345)
sim_1 <- mv_simulate(type = "D1")
sim_2 <- mv_simulate(type = "D2")
sim_3 <- mv_simulate(type = "D3")
sim_4 <- mv_simulate(type = "D4")
sim_5 <- mv_simulate(type = "D5")
sim_6a <- mv_simulate(type = "D6")
sim_6b <- mv_simulate(type = "D6", beta=7, n=200, K=5, sigma=0.5)

X <- sim_6a$data
mv <- c(2,2,2,1,1,2)
gamma <- 2 
Xlist <- list(X[,1:2], X[,3:4], X[,5:6], matrix(X[,7], ncol=1), 
              matrix(X[,8], ncol=1), X[,9:10])
X_scale <- maskmeans:::scaleview(X, mv)

#-------------------------------------------------------------------
## Double-check that all functions provide the same result as before
#-------------------------------------------------------------------

#**************************************
## Test 1: hard clustering aggregation
#**************************************
cluster_init <- kmeans(Xlist[[1]], 20)$cluster
set.seed(12345)
hard_agglom <- maskmeans(mv_data=X, mv=mv, clustering_init=cluster_init, 
                         type = "aggregation", gamma=gamma) 
  
set.seed(12345)
hard_agglom_old <- maskmeans:::hmv1(X_scale, mv=mv, gamma=gamma, 
                        cluster.init=cluster_init, 
                        weightsopt = TRUE)
  
all.equal(hard_agglom$weights, hard_agglom_old$weights,
          check.attributes = FALSE)              
all.equal(hard_agglom$criterion, hard_agglom_old$CRIT)               
all.equal(hard_agglom$merged_clusters, hard_agglom_old$merge)

#**************************************
## Test 2: soft clustering aggregation
#**************************************
set.seed(12345)
proba_init <- matrix(runif(nrow(X)*20), ncol=20)
proba_init <- proba_init / rowSums(proba_init)
# library(fclust)
# proba_init <- FKM(X, k=5)$U
soft_agglom <- maskmeans(mv_data=X, mv=mv, clustering_init=proba_init, 
                          type = "aggregation", gamma=gamma) 
set.seed(12345)
soft_agglom_old <- maskmeans:::hmvprobapost(X_scale, mv=mv, gamma=gamma, 
                                 probapost.init=proba_init)

all.equal(soft_agglom$weights, soft_agglom_old$weights, 
          check.attributes=FALSE)
all.equal(soft_agglom$criterion, soft_agglom_old$CRIT)           
all.equal(soft_agglom$merged_clusters, soft_agglom_old$merge)
  
#**************************************  
## Test 3: hard clustering splitting
#**************************************
set.seed(12345)
cluster_init <- kmeans(Xlist[[1]], 5)$cluster
hard_split <- maskmeans(mv_data=X, mv=mv, clustering_init=cluster_init, 
                        type = "splitting", Kmax=20,
                        perCluster_mv_weights = FALSE)  

set.seed(12345)
hard_split_old <- maskmeans:::splittingClusters(X=X_scale, mv=mv, gamma=gamma, 
                             Kmax=20, cluster.init=cluster_init,
                             weightsopt = TRUE, testkmeans = TRUE) 

all.equal(hard_split$weights, hard_split_old$weights, 
          check.attributes = FALSE) 
all.equal(hard_split$criterion, hard_split_old$CRIT[-1])  
## Differences just due to label switching
all.equal(hard_split$split_clusters, hard_split_old$clustersplithist)  
## Differences just due to label switching
all.equal(hard_split$ksplit, hard_split_old$ksplit, 
          check.attributes = FALSE)  
## Differences just due to label switching
all.equal(hard_split$withinss, hard_split_old$withinss, 
          check.attributes = FALSE)     


#**************************************
## Test 4: hard clustering splitting with per-weights
#**************************************
set.seed(12345)
cluster_init <- kmeans(Xlist[[1]], 10)$cluster
hard_split_perCluster <- maskmeans(mv_data=X, mv=mv, 
                                   clustering_init=cluster_init, type = "splitting", 
                                   Kmax=20, perCluster_mv_weights=TRUE, gamma=1) 

set.seed(12345)
hard_split_old_perCluster <- maskmeans:::splittingClustersbis(X=X_scale, mv=mv, gamma=1, 
                                                  Kmax=20, cluster.init=cluster_init) 

## Note: these are not identical as there was an error in the original code
mapply(all.equal, hard_split_perCluster$weights, 
       hard_split_old_perCluster$weights, 
       check.attributes = FALSE)             
all.equal(hard_split_perCluster$criterion, 
          hard_split_old_perCluster$CRIT[-1])                        
all.equal(hard_split_perCluster$split_clusters, 
          hard_split_old_perCluster$clustersplithist)     
all.equal(hard_split_perCluster$ksplit, hard_split_old_perCluster$ksplit, 
          check.attributes = FALSE)                        
all.equal(hard_split_perCluster$withinss, hard_split_old_perCluster$withinss, 
          check.attributes = FALSE)           


#**************************************
## Test 5: soft clustering splitting
#**************************************
\dontrun{
  set.seed(12345)
  proba_init <- matrix(runif(nrow(X)*5), ncol=5)
  proba_init <- proba_init / rowSums(proba_init)
  soft_split <- maskmeans(mv_data=X, mv=mv, clustering_init=proba_init, 
                           type = "splitting", gamma=gamma, delta = 2,
                           perCluster_mv_weights = FALSE, Kmax = 16,
                           verbose=TRUE, parallel=TRUE) 
  set.seed(12345)
  soft_split_old <- maskmeans:::splittingProbapost(X=X_scale, mv=mv,
                                                    gamma=gamma, delta=2, Kmax=7, 
                                                    probapost.init=proba_init)
  all.equal(soft_split$weights, soft_split_old$weights,
            check.attributes=FALSE)
  all.equal(soft_split$criterion, soft_split_old$CRIT)
  ## Columns are not in the same order here but otherwise equal
  all.equal(soft_split$probapost, soft_split_old$probapost)
  
}



#**************************************
## Test 6: soft clustering splitting with per-weights
#**************************************
\dontrun{
  set.seed(12345)
  soft_split_perCluster <- maskmeans(mv_data=X, mv=mv, clustering_init=proba_init, 
                                      type = "splitting", gamma=gamma, delta = 2,
                                      perCluster_mv_weights = TRUE, Kmax = 16,
                                      parallel=FALSE) 
  set.seed(12345)
  soft_split_old_perCluster <- maskmeans:::splittingProbapostbis(X=X_scale, mv=mv,
     gamma=gamma, delta=2, Kmax=7, probapost.init=proba_init)
  all.equal(soft_split_perCluster$weights, soft_split_old_perCluster$weights, 
             check.attributes=FALSE)
  all.equal(soft_split_perCluster$criterion, soft_split_old_perCluster$CRIT)           
  all.equal(soft_split_perCluster$probapost, soft_split_old_perCluster$probapost)
}

#**************************************
## Other testing idea: using Xlist instead
#**************************************
cluster_init <- kmeans(Xlist[[1]], 10)$cluster
hard_agglom_list <- maskmeans(mv_data=Xlist, clustering_init=cluster_init, 
                         type = "aggregation", gamma=gamma) 
table(maskmeans_cutree(hard_agglom_list, K=6, clustering_init=cluster_init)$classif)

#**************************************
## Plot functions
#**************************************

mv_plot(mv_data=sim_6a$data, mv=mv, labels=sim_6a$labels[,1])
mv_plot(mv_data=sim_1$data, mv=c(2,2,2,2), labels=sim_1$labels[,1])
mv_plot(mv_data=sim_2$data, mv=c(2,2,2,2), labels=sim_2$labels[,1])
mv_plot(mv_data=Xlist, labels=sim_6a$labels[,1])

p <- maskmeans_plot(hard_agglom)
p <- maskmeans_plot(soft_agglom)
p <- maskmeans_plot(hard_split)  
p <- maskmeans_plot(hard_split, type="tree")  
p <- maskmeans_plot(hard_split, type="tree", edge_arrow=FALSE)  
p <- maskmeans_plot(hard_split_perCluster, type="tree")
p <- maskmeans_plot(hard_split_perCluster, type = "tree_perClusterWeights")
p <- maskmeans_plot(hard_split_perCluster)

## Tree plots look weird here
\dontrun{
  p <- maskmeans_plot(soft_split, type = "tree")  
  p <- maskmeans_plot(soft_split_perCluster)    
}

## Plot weights in the final splits originating from intial cluster 8 (using final_K)
s <- split_zoom(hard_split_perCluster, initial_cluster = 8, mv_names = letters[1:6])



