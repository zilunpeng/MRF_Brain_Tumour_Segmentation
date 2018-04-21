function healthy_cls_prob = read_healthy_class_prob(img_no)
    path = '/Users/pengzilun/Documents/mcgill/mcgill_homework/ecse_626/project/BRATS-2/Image_Data/HG/';
    path = char(strcat(path,sprintf("%04d",img_no)));
    healthy_cls_prob{1} = mhd_read_image(strcat(path, '/gm_prob_map.mha'));
    healthy_cls_prob{2} = mhd_read_image(strcat(path, '/wm_prob_map.mha'));
    healthy_cls_prob{3} = mhd_read_image(strcat(path, '/csf_prob_map.mha'));
end