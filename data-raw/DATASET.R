## code to prepare `DATASET` dataset goes here

usethis::use_data(DATASET, overwrite = TRUE)

# Convert `Q_list` to an J*K matrix


# Convert 'L_real_list' to an (N*J*T) array
dim(L_real_list[[1]])
L_real_array <- List2Array(L_real_list)
dim(L_real_array)

use_data(L_real_array, overwrite=T)

Q_list
