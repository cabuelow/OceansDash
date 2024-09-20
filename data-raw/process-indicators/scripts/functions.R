# function to extract tiles' values for AGB and SOC

getvalue <- function(x, y) { # x is spatVector, y is list of raster files 
  
  # get extent of tif for intersecting with typo
  extent <- sapply(y, ext) # extract extent
  ext_vect <- sapply(extent, vect, crs = crs(x)) # convert extent to a list of SpatVector
  names(ext_vect) <- 1:length(y)# naming list by using raster list sequence number
  
  results <- list()
  
  for (i in 1:nrow(x)) {
    
    x_i <- x[i,]
    
    # to generate an index for rast files that intersect with typo_i
    test <- ext_vect[sapply(ext_vect, is.related, x_i, relation = "intersects") == TRUE]  
    index <- as.numeric(names(test))
    # select rast
    if (length(test) > 0) {
      rast_i <- vrt(fils[index], paste0(temp, "/v.vrt"), overwrite = T) # select and merge if multiple
      
      value <- exact_extract(rast_i, st_as_sf(x_i), c('mean'))
      results[[i]] <- value
      names(results)[i] <- values(x_i[1,1])
    }else{
      value <- NA
      results[[i]] <- value
      names(results)[i] <- values(x_i[1,1])
    }
  }
  return(bind_rows(results, .id = "id"))
}
