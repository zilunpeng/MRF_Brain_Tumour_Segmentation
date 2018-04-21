function ground_truth = get_ground_truth(img_no)
    path = '/Users/pengzilun/Documents/mcgill/mcgill_homework/ecse_626/project/BRATS-2/Image_Data/HG/';
    temp_path = char(strcat(path,sprintf("%04d",img_no)));
    file = dir(char(strcat(temp_path,'/VSD.Brain_3more.XX.XX.OT/*.mha')));
    ground_truth = mhd_read_image(strcat(file.folder,'/',file.name));
end