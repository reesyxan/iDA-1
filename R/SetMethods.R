#' Generic method to input data to iDA 
#' 
#' @param object The object to run iDA on
#' @param ... Additonal arguments passed to object constructors
#' @return iDA output with clustering, gene weights, and cell weights
#' @export
#' 
#' 

setGeneric("iDA", signature=c("object"), 
function(object, ...) standardGeneric("iDA"))


#' Method for SingleCellExperiment object to input data to iDA 
#' 
#' @param object The single cell experiment object to run iDA on
#' @param ... Additonal arguments passed to object constructors
#' @importFrom  SingleCellExperiment SingleCellExperiment
#' @return SingleCellExperiment object with iDA cell weights and gene weights stored in reducedDims and cluster assignemts
#' stored in rowLabels
#' @export
#' 
#' 

setMethod("iDA", "SingleCellExperiment",
          function(object, ...) {
            counts <- assay(object)
            
            iDA_sce <- iDA(t(counts))
            
            reducedDims(object) <- list(iDA_cellweights = iDA_sce[2], iDA_geneweights = iDA_sce[3])
            rowLabels(object) <- iDA_sce[1]
            
            return(object)
          })


#' Method for Seurat object to input data to iDA 
#' 
#' @param object The single cell experiment object to run iDA on
#' @param ... Additonal arguments passed to object constructors
#' @importFrom Seurat Seurat
#' @return Seurat object with iDA cell weights and gene weights stored in object[["iDA"]] and cluster assignemts stored in rowLabels
#' @export
#' 
#' 

setMethod("iDA", "Seurat",
          function(object, ...) {
            
            if (!('scaled.data' %in% slotNames(object))){
              object <- NormalizeData(object, normalization.method = "LogNormalize", scale.factor = 10000)
              all.genes <- rownames(object)
              object <- ScaleData(object)
              counts <- object@scale.data
            } else {
              counts <- object@scale.data
            }
            
            
            iDA_seurat <- iDA(counts, scaled = TRUE, ...)
            
            object[["iDA"]] <- CreateDimReducObject(embeddings = iDA_seurat[2], key = "LD", loadings = iDA_seurat[3], assay = DefaultAssay(object))
            object@meta.data[["iDA_clust"]] <- iDA_seurat[1]
        
            return(object)
          })
class(pbmc)
