#' @export
print.hmcdm.DINA_HO <- function(x, ...){
  cat("\nModel:",formatC(x$Model),"\n")
  
  cat("\nSample Size:", x$N)
  cat("\nNumber of Items:", x$Jt*x$T)
  cat("\nNumber of Time Points:", x$T,"\n")
  
  cat("\nChain Length:",x$chain_length)
  cat(", burn-in:",x$burn_in,"\n")
}


#' @export
summary.hmcdm.DINA_HO <- function(object, ...){
  point_estimates <- point_estimates_learning(object,"DINA_HO",
                                              object$N,
                                              object$Jt,
                                              object$K,
                                              object$T,
                                              alpha_EAP = F)
  N <- object$N
  T <- object$T
  Jt <- object$Jt
  J <- Jt*T
  Y_sim <- Dense2Sparse(object$Response, object$test_order, object$Test_versions)
  Q_matrix <- object$Qs[,,1]
  if(T > 1){
    for(i in 2:T){
      Q_matrix <- rbind(Q_matrix, object$Qs[,,i])
    }
  }
  HMDCM_fit <- Learning_fit(object, "DINA_HO", Y_sim,Q_matrix, object$test_order, object$Test_versions, object$Q_examinee)
  PPP_total_scores <- matrix(NA,N,T)
  Y_sim_array <- Sparse2Dense(Y_sim, object$test_order, object$Test_versions)
  for(i in 1:N){
    for(t in 1:T){
      f <- stats::ecdf(HMDCM_fit$PPs$total_score_PP[i,t,])
      tot_it = sum(Y_sim_array[i,,t])
      PPP_total_scores[i,t] = f(tot_it)
    }
  }
  PPP_item_means <- numeric(J)
  PPP_item_ORs <- matrix(NA,J,J)
  Y_sim_collapsed <- matrix(NA,N,J)
  for(i in 1:N){
    test_i <- object$Test_versions[i]
    for(t in 1:T){
      t_i = object$test_order[test_i,t]
      Y_sim_collapsed[i,(Jt*(t_i-1)+1):(Jt*t_i)] <- Y_sim_array[i,,t]
    }
  }
  Observed_ORs <- OddsRatio(N,J,Y_sim_collapsed)
  for(j in 1:J){
    f1 <- stats::ecdf(HMDCM_fit$PPs$item_mean_PP[j,])
    mean_obs <- mean(Y_sim_collapsed[,j])
    PPP_item_means[j] = f1(mean_obs)
  }
  for(j in 1:(J-1)){
    for(jp in (j+1):J){
      f2 <- stats::ecdf(HMDCM_fit$PPs$item_OR_PP[j,jp,])
      PPP_item_ORs[j,jp] <- f2(Observed_ORs[j,jp])
    }
  }
  
  item_parameters <- cbind(point_estimates$ss_EAP,point_estimates$gs_EAP)
  colnames(item_parameters) <- c("Slipping","Guessing")
  pis <- point_estimates$pis_EAP
  colnames(pis) <- "Class Probabilities"
  lambdas <- point_estimates$lambdas_EAP
  colnames(lambdas) <- "lambdas"
  
  res <- list(model = "DINA_HO",
                 item_parameters = item_parameters,
                 class_probabilities = pis,
                 transition_coefficients = lambdas,
                 DIC = HMDCM_fit$DIC,
                 PPP_total_scores = PPP_total_scores,
                 PPP_item_means = PPP_total_scores,
                 PPP_item_ORs = PPP_item_ORs)
  class(res) <- "summary.hmcdm.DINA_HO"
  res
}


#' @export
print.summary.hmcdm.DINA_HO <- function(x, ...){
  
  digits <- max(3, getOption("digits") - 3)
  
  cat("\nModel:",x$model,"\n")
  
  cat("\nItem Parameters:\n")
  print(x$item_parameters, digits=digits)
  
  cat("\nClass Probabilities:\n")
  print(x$class_probabilities, digits=digits)
  
  cat("\nTransition Coefficients:\n")
  print(x$transition_coefficients, digits=digits)
  
  cat("\nModel Fit Measures:\n")
  cat("DIC:")
  print(x$DIC[3,], digits=digits+3)
  
  invisible(x)
}




