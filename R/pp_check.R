#' @title Graphical posterior predictive checks for hidden Markov cognitive diagnosis model
#' @description `pp_check` method for class `hmcdm`.
#' @param object a fitted model object of class "`hmcdm`".
#' @param plotfun A character string naming the type of plot. The list of available 
#' plot functions include `"dens_overlay"`, `"hist"`, `"stat_2d"`, `"scatter_avg"`, `"error_scatter_avg"`.
#' The default function is `"dens_overlay"`.
#' @param type A character string naming the type of posterior predictive distributions to plot. 
#' The list of available types include `"total_score"`, `"M1"`, `"M2"`. The default type is `"total_score"`.
#' @seealso 
#' [bayesplot::ppc_dens_overlay()]
#' [bayesplot::ppc_stat()]
#' [bayesplot::ppc_stat_2d()]
#' [bayesplot::ppc_scatter_avg()]
#' [bayesplot::ppc_error_scatter_avg()]
#' @references 
#' Zhang, S., Douglas, J. A., Wang, S. & Culpepper, S. A., 2019, Handbook of Diagnostic Classification Models: Models and Model Extensions, Applications, Software Packages. von Davier, M. & Lee, Y-S. (eds.). Springer, p. 503-524
#' @examples
#' \donttest{
#' output_FOHM = hmcdm(Y_real_array,Q_matrix,"DINA_FOHM",Test_order,Test_versions,10000,5000)
#' library(bayesplot)
#' pp_check(output_FOHM)
#' pp_check(output_FOHM, plotfun="hist", type="M1")
#' }
#' @export
pp_check.hmcdm <- function(object,plotfun="dens_overlay",type="total_score"){
  N <- dim(object$input_data$Response)[1]
  T <- dim(object$input_data$Response)[3]
  Jt <- dim(object$input_data$Response)[2]
  J <- Jt*T
  
  Y_sim <- Dense2Sparse(object$input_data$Response, object$input_data$Test_order, object$input_data$Test_versions)
  Y_sim_array <- Sparse2Dense(Y_sim, object$input_data$Test_order, object$input_data$Test_versions)
  Test_order <- object$input_data$Test_order
  Test_versions <- object$input_data$Test_versions
  Q_matrix <- Array2Mat(object$input_data$Qs)
  Q_examinee <- object$input_data$Q_examinee
  Y_sim_collapsed <- matrix(NA,N,J)
  for(i in 1:N){
    test_i <- object$input_data$Test_versions[i]
    for(t in 1:T){
      t_i = object$input_data$Test_order[test_i,t]
      Y_sim_collapsed[i,(Jt*(t_i-1)+1):(Jt*t_i)] <- Y_sim_array[i,,t]
    }
  }
  
  if(object$Model == "DINA_HO"){
    object_fit <- Learning_fit(object, "DINA_HO", Y_sim,Q_matrix, 
                          Test_order, Test_versions, Q_examinee)
  }
  if(object$Model == "DINA_HO_RT_sep" | object$Model == "DINA_HO_RT_joint"){
    L_sim <- Dense2Sparse(object$input_data$Latency, object$input_data$Test_order, object$input_data$Test_versions)
    object_fit <- Learning_fit(object,object$Model,Y_sim,Q_matrix,
                                  object$input_data$Test_order,object$input_data$Test_versions,
                                  Q_examinee=object$input_data$Q_examinee,
                                  Latency_array = object$input_data$Latency, G_version = object$input_data$G_version)
  }
  if(object$Model == "rRUM_indept" | object$Model == "NIDA_indept"){
    object_fit <- Learning_fit(object,object$Model,Y_sim,Q_matrix,
                                    object$input_data$Test_order,object$input_data$Test_versions,
                                    R=object$input_data$R)
  }
  if(object$Model == "DINA_FOHM"){
    object_fit <- Learning_fit(object,"DINA_FOHM",Y_sim,Q_matrix,
                          object$input_data$Test_order,object$input_data$Test_versions)
  }
  
  if(type=="total_score"){
    ## total score
    total_score_obs <- matrix(NA, N, T)
    for(t in 1:T){
      total_score_obs[,t] <- rowSums(object$input_data$Response[,,t])
    }
    obs <- rowSums(total_score_obs)
    pp <- apply(object_fit$PPs$total_score_PP,1,colSums)
  }
  if(type=="M1"){
    ## Item means
    obs <- rep(NA, J)
    for(j in 1:J){
      obs[j] <- mean(Y_sim_collapsed[,j])
    }
    pp <- t(object_fit$PPs$item_mean_PP)
  }
  
  if(type=="M2"){
    ## Item log odds ratio
    Observed_ORs <- OddsRatio(N,J,Y_sim_collapsed)
    ORs_obs <- Observed_ORs[upper.tri(Observed_ORs)]
    obs <- log(ORs_obs)
    CL <- object$chain_length-object$burn_in
    ORs_pp <- matrix(NA, nrow=CL, ncol=length(ORs_obs))
    for(cl in 1:CL){
      ORs_pp[cl,] <- object_fit$PPs$item_OR_PP[,,cl][upper.tri(object_fit$PPs$item_OR_PP[,,cl])]
    }
    pp <- log(ORs_pp)
  }

  if(plotfun=="dens_overlay"){# Compare distribution of y to distributions of multiple yrep datasets
    bayesplot::color_scheme_set("red")
    result <- bayesplot::ppc_dens_overlay(y=obs, yrep=pp)
  }
  if(plotfun=="hist"){# Check histograms of test statistics
    bayesplot::color_scheme_set("blue")
    result <- bayesplot::ppc_stat(y=obs, yrep=pp)
  }
  if(plotfun=="stat_2d"){# Scatterplot of two test statistics
    bayesplot::color_scheme_set("blue")
    result <- bayesplot::ppc_stat_2d(y=obs, yrep=pp)
  }
  if(plotfun=="scatter_avg"){  # Scatterplot of y vs. average yrep
    bayesplot::color_scheme_set("blue")
    result <- bayesplot::ppc_scatter_avg(y = obs, yrep = pp)
  }
  if(plotfun=="error_scatter_avg"){# predictive errors
    bayesplot::color_scheme_set("blue")
    result <- bayesplot::ppc_error_scatter_avg(y = obs, yrep = pp)
  }
  
  return(result)
}



