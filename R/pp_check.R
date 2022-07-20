#' @export
pp_check.hmcdm <- function(x,plotfun="dens_overlay",type="total_score",...){
  N <- dim(x$input_data$Response)[1]
  T <- dim(x$input_data$Response)[3]
  Jt <- dim(x$input_data$Response)[2]
  J <- Jt*T
  
  Y_sim <- Dense2Sparse(x$input_data$Response, x$input_data$Test_order, x$input_data$Test_versions)
  Y_sim_array <- Sparse2Dense(Y_sim, x$input_data$Test_order, x$input_data$Test_versions)
  Test_order <- x$input_data$Test_order
  Test_versions <- x$input_data$Test_versions
  Q_matrix <- Array2Mat(x$input_data$Qs)
  Q_examinee <- x$input_data$Q_examinee
  Y_sim_collapsed <- matrix(NA,N,J)
  for(i in 1:N){
    test_i <- x$input_data$Test_versions[i]
    for(t in 1:T){
      t_i = x$input_data$Test_order[test_i,t]
      Y_sim_collapsed[i,(Jt*(t_i-1)+1):(Jt*t_i)] <- Y_sim_array[i,,t]
    }
  }
  
  if(x$Model == "DINA_HO"){
    x_fit <- Learning_fit(x, "DINA_HO", Y_sim,Q_matrix, 
                          Test_order, Test_versions, Q_examinee)
  }
  if(x$Model == "DINA_HO_RT_sep" | x$Model == "DINA_HO_RT_joint"){
    L_sim <- Dense2Sparse(x$input_data$Latency, x$input_data$Test_order, x$input_data$Test_versions)
    x_fit <- Learning_fit(x,x$Model,Y_sim,Q_matrix,
                                  x$input_data$Test_order,x$input_data$Test_versions,
                                  Q_examinee=x$input_data$Q_examinee,
                                  Latency_array = x$input_data$Latency, G_version = x$input_data$G_version)
  }
  if(x$Model == "rRUM_indept" | x$Model == "NIDA_indept"){
    x_fit <- Learning_fit(x,x$Model,Y_sim,Q_matrix,
                                    x$input_data$Test_order,x$input_data$Test_versions,
                                    R=x$input_data$R)
  }
  if(x$Model == "DINA_FOHM"){
    x_fit <- Learning_fit(x,"DINA_FOHM",Y_sim,Q_matrix,
                          x$input_data$Test_order,x$input_data$Test_versions)
  }
  
  if(type=="total_score"){
    ## total score
    total_score_obs <- matrix(NA, N, T)
    for(t in 1:T){
      total_score_obs[,t] <- rowSums(x$input_data$Response[,,t])
    }
    obs <- rowSums(total_score_obs)
    pp <- apply(x_fit$PPs$total_score_PP,1,colSums)
  }
  if(type=="M1"){
    ## Item means
    obs <- rep(NA, J)
    for(j in 1:J){
      obs[j] <- mean(Y_sim_collapsed[,j])
    }
    pp <- t(x_fit$PPs$item_mean_PP)
  }
  
  if(type=="M2"){
    ## Item log odds ratio
    Observed_ORs <- OddsRatio(N,J,Y_sim_collapsed)
    ORs_obs <- Observed_ORs[upper.tri(Observed_ORs)]
    obs <- log(ORs_obs)
    CL <- x$chain_length-x$burn_in
    ORs_pp <- matrix(NA, nrow=CL, ncol=length(ORs_obs))
    for(cl in 1:CL){
      ORs_pp[cl,] <- x_fit$PPs$item_OR_PP[,,cl][upper.tri(x_fit$PPs$item_OR_PP[,,cl])]
    }
    pp <- log(ORs_pp)
  }

  if(plotfun=="dens_overlay"){# Compare distribution of y to distributions of multiple yrep datasets
    color_scheme_set("red")
    result <- bayesplot::ppc_dens_overlay(y=obs, yrep=pp)
  }
  if(plotfun=="hist"){# Check histograms of test statistics
    color_scheme_set("blue")
    result <- bayesplot::ppc_stat(y=obs, yrep=pp)
  }
  if(plotfun=="stat_2d"){# Scatterplot of two test statistics
    color_scheme_set("blue")
    result <- bayesplot::ppc_stat_2d(y=obs, yrep=pp)
  }
  if(plotfun=="scatter_avg"){  # Scatterplot of y vs. average yrep
    color_scheme_set("blue")
    result <- bayesplot::ppc_scatter_avg(y = obs, yrep = pp)
  }
  if(plotfun=="error_scatter_avg"){# predictive errors
    color_scheme_set("blue")
    result <- bayesplot::ppc_error_scatter_avg(y = obs, yrep = pp)
  }
  
  return(result)
}



