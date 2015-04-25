list.of.packages <- c("twitteR", "parallel")
new.packages <- list.of.packages[!(list.of.packages %in% installed.packages()[,"Package"])]
if(length(new.packages)) install.packages(new.packages)
lapply(list.of.packages, require, character.only=T)

# library("ROAuth")
# library("twitteR")
# library("wordcloud")
# library("tm")
# library("httr")
# library("parallel")
nc=getOption("mc.cores", 2L)

#necessary file for Windows
#download.file(url="http://curl.haxx.se/ca/cacert.pem", destfile="cacert.pem")

setup_twitter_oauth('GPI5CNx6tabl6J1M24lQJmCkU', 'YxmKTz1t4uLWSQDKu1h3p0l1g6zSf6PWLPVaAn1ppao23a8ZDY', '86753315-rldhPYu5C17xEzoVMADKNyefqgw1teg0VduH14TVi','Db9volDQ7i0VEjJ85hMHqTQ9nIL1o2w37OJkjAcG1khHz')

users_c <- read.csv('users_prueba.csv', colClasses = c('factor', 'character'))
users <- users_c[1:2,]

#############################################################


users_list <- mclapply(1:nrow(users), function(i) {getUser(as.character(users[i,1]))}, mc.cores=nc)
followers_list <- mclapply(1:2, function(i) {users_list[[i]]$getFollowers()}, mc.cores=nc)
followees_list <- mclapply(1:2, function(i) {users_list[[i]]$getFriends()}, mc.cores=nc)

followers_id_list <- mclapply(1:2, function(i) {users_list[[i]]$getFollowerIDs()}, mc.cores=nc)
followees_id_list <- mclapply(1:2, function(i) {users_list[[i]]$getFriendIDs()}, mc.cores=nc)

adj <- rbind(
  cbind(users$id[1], followees_id_list[[1]]),
  cbind(followers_id_list[[1]], users$id[1]))

followers_id <- unique(unlist(sapply(followers_list, names)))
followees_id <- unique(unlist(sapply(followees_list, names)))

users_id <- unique(c(t(users$id), followers_id, followees_id))


######

followers_id_list <- mclapply(users$id, function(i) {getUser(i)$getFollowerIDs()}, mc.cores=nc)
names(followers_id_list) <- users$id
followees_id_list <- mclapply(users$id, function(i) {getUser(i)$getFriendIDs()}, mc.cores=nc)
names(followees_id_list) <- users$id

temp <- unique(c(unlist(followees_id_list), unlist(followers_id_list)))
new_ids <- setdiff(temp, users$id)
new_ids <- new_ids[1:2]

followers_id_list2 <- mclapply(new_ids, function(i) {getUser(i)$getFollowerIDs()}, mc.cores=nc)
names(followers_id_list2) <- new_ids
followees_id_list2 <- mclapply(new_ids, function(i) {getUser(i)$getFriendIDs()}, mc.cores=nc)
names(followees_id_list2) <- new_ids
temp<- append(followers_id_list, followers_id_list2)

