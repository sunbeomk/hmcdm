#' Observed response accuracy array
#' 
#' This data set contains each subject's observed response accuracy (0/1) at all time points in the Spatial 
#' Rotation Learning Program.
#' @format An array of dimensions N-by-J-by-T. Each slice of the array is an N-by-J matrix, containing the
#' subjects' response accuracy to each item at time point t.
#' @source Spatial Rotation Learning Experiment at UIUC between Fall 2015 and Spring 2016.
#' @author Shiyu Wang, Yan Yang, Jeff Douglas, and Steve Culpepper
"Y_real_array"


#' Observed response times array
#' 
#' This data set contains the observed latencies of responses of all subjects to all questions in the Spatial Rotation 
#' Learning Program.
#' @format An array of dimensions N-by-J-by-T. Each slice of the array is an N-by-J matrix, containing the
#' subjects' response times in seconds to each item at time point t.
#' @source Spatial Rotation Learning Experiment at UIUC between Fall 2015 and Spring 2016.
#' @author Shiyu Wang, Yan Yang, Jeff Douglas, and Steve Culpepper
"L_real_array"


#' Q-matrix
#' 
#' This data set contains the Q matrix of the items in the Spatial Rotation Learning Program.
#' @format A J-by-K matrix, indicating the item-skill relationship.
#' @source Spatial Rotation Learning Experiment at UIUC between Fall 2015 and Spring 2016.
#' @author Shiyu Wang, Yan Yang, Jeff Douglas, and Steve Culpepper
"Q_matrix"


#' Subjects' test version
#' 
#' This data set contains each subject's test version in the Spatial Rotation Learning Program.
#' @format A vector of length N, containing each subject's test version ranging from 1 to T.
#' @source Spatial Rotation Learning Experiment at UIUC between Fall 2015 and Spring 2016.
#' @author Shiyu Wang, Yan Yang, Jeff Douglas, and Steve Culpepper
"Test_versions"


#' Test block ordering of each test version
#' 
#' This data set contains the item block ordering of each version of the test.
#' @format A T-by-T matrix, each row is the order of item blocks for that test version. 
#' For example, the first row is the order of item block administration (1-2-3-4-5) to subjects with test
#' version 1. 
#' @source Spatial Rotation Learning Experiment at UIUC between Fall 2015 and Spring 2016.
#' @author Shiyu Wang, Yan Yang, Jeff Douglas, and Steve Culpepper
'Test_order'

