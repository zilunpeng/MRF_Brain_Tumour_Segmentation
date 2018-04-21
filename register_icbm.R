setwd("/Users/pengzilun/Documents/mcgill/mcgill_homework/ecse_626/project")
library(ANTsR)
library(stringr)

#Read wm,gm,csf probability map 
gm_prob_map_path <- "/Users/pengzilun/Documents/mcgill/mcgill_homework/ecse_626/project/mni_icbm152_nlin_sym_09c_nifti/mni_icbm152_nlin_sym_09c/mni_icbm152_gm_tal_nlin_sym_09c.nii"
gm_prob_map <-  antsImageRead(gm_prob_map_path)
wm_prob_map_path <- "/Users/pengzilun/Documents/mcgill/mcgill_homework/ecse_626/project/mni_icbm152_nlin_sym_09c_nifti/mni_icbm152_nlin_sym_09c/mni_icbm152_wm_tal_nlin_sym_09c.nii"
wm_prob_map <-  antsImageRead(wm_prob_map_path)
csf_prob_map_path <- "/Users/pengzilun/Documents/mcgill/mcgill_homework/ecse_626/project/mni_icbm152_nlin_sym_09c_nifti/mni_icbm152_nlin_sym_09c/mni_icbm152_csf_tal_nlin_sym_09c.nii"
csf_prob_map <-  antsImageRead(csf_prob_map_path)

#Read T1 template
t1_template_path <- "/Users/pengzilun/Documents/mcgill/mcgill_homework/ecse_626/project/mni_icbm152_nlin_sym_09c_nifti/mni_icbm152_nlin_sym_09c/mni_icbm152_t1_tal_nlin_sym_09c.nii"
mi <- antsImageRead(t1_template_path)

#Apply mask to template (skull stripping)
t1_mask <- antsImageRead('/Users/pengzilun/Documents/mcgill/mcgill_homework/ecse_626/project/mni_icbm152_nlin_sym_09c_nifti/mni_icbm152_nlin_sym_09c/mni_icbm152_t1_tal_nlin_sym_09c_mask.nii')
mi <- maskImage(mi,t1_mask,binarize=FALSE)

#N4 bias field correction
mi <- n4BiasFieldCorrection(mi,shrinkFactor = 4)

for (img_no in 22:26) {
  #Load patient's T1 MRI and read image
  t1_data_path <- paste0("/Users/pengzilun/Documents/mcgill/mcgill_homework/ecse_626/project/BRATS-2/Image_Data/HG/",str_pad(img_no,4,pad="0"),"/VSD.Brain.XX.O.MR_T1/*.mha")
  t1_data_path <- Sys.glob(t1_data_path)
  fi <- antsImageRead(t1_data_path)  
  
  #Read tumour mask and apply to fi
  #tumor_mask_path <- paste0("/Users/pengzilun/Documents/mcgill/mcgill_homework/ecse_626/project/BRATS-2/Image_Data/HG/",str_pad(img_no,4,pad="0"),"/tumor_mask.nii")
  #tumor_mask <- antsImageRead(tumor_mask_path)
  #fi <- maskImage(fi,tumor_mask,binarize=FALSE)
  
  #N4 bias field correction
  fi <- n4BiasFieldCorrection(fi,shrinkFactor = 4)
      
  #Register ICBM T1 template onto patient's T1 
  mytx <- antsRegistration(fixed=fi, moving=mi, typeofTransform = c('SyN') )
  
  #Save the result (for debugging)
  #mywarpedimage <- antsApplyTransforms( fixed=fi, moving=mi, transformlist=mytx$fwdtransforms )
  #antsImageWrite( mywarpedimage, "/Users/pengzilun/Documents/mcgill/mcgill_homework/ecse_626/project/test.nii")  
  
  # #Register gray matter, white matter and csf's probability map on to patient's MRI volume using mytx
  gm_warped <- antsApplyTransforms(fixed=fi, moving=gm_prob_map, transformlist=mytx$fwdtransforms)
  wm_warped <- antsApplyTransforms(fixed=fi, moving=wm_prob_map, transformlist=mytx$fwdtransforms)
  csf_warped <- antsApplyTransforms(fixed=fi, moving=csf_prob_map, transformlist=mytx$fwdtransforms)

  #Save the above outputs
   gm_prob_map_path <- paste0("/Users/pengzilun/Documents/mcgill/mcgill_homework/ecse_626/project/BRATS-2/Image_Data/HG/",str_pad(img_no,4,pad="0"),"/gm_prob_map.mha")
   antsImageWrite(gm_warped, gm_prob_map_path)
   wm_prob_map_path <- paste0("/Users/pengzilun/Documents/mcgill/mcgill_homework/ecse_626/project/BRATS-2/Image_Data/HG/",str_pad(img_no,4,pad="0"),"/wm_prob_map.mha")
   antsImageWrite(wm_warped, wm_prob_map_path)
   csf_prob_map_path <- paste0("/Users/pengzilun/Documents/mcgill/mcgill_homework/ecse_626/project/BRATS-2/Image_Data/HG/",str_pad(img_no,4,pad="0"),"/csf_prob_map.mha")
   antsImageWrite(csf_warped, csf_prob_map_path)
}


