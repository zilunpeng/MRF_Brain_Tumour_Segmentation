function [flair_data,t1_data,t1c_data,t2_data] = get_MRI_vols(img_no)
    path = '/Users/pengzilun/Documents/mcgill/mcgill_homework/ecse_626/project/BRATS-2/Image_Data/HG/';
    temp_path = char(strcat(path,sprintf("%04d",img_no)));
    file = dir(char(strcat(temp_path,'/VSD.Brain.XX.O.MR_Flair/*.mha')));
    flair_data = mhd_read_image(strcat(file.folder,'/',file.name));
    file = dir(char(strcat(temp_path,'/VSD.Brain.XX.O.MR_T1/*.mha')));
    t1_data = mhd_read_image(strcat(file.folder,'/',file.name));
    file = dir(char(strcat(temp_path,'/VSD.Brain.XX.O.MR_T1c/*.mha')));
    t1c_data = mhd_read_image(strcat(file.folder,'/',file.name));
    file = dir(char(strcat(temp_path,'/VSD.Brain.XX.O.MR_T2/*.mha')));
    t2_data = mhd_read_image(strcat(file.folder,'/',file.name));
%     temp = flair_data(:,:,90);
%     imshow(temp,[0,max(max(temp))])
end