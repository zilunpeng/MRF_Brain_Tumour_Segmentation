%Go through the ground truth of each patient's MRI and create a mask for
%tumor
function create_tumor_mask(img_numbers)
    for i=1:img_numbers
        %get ground_truth
        data = get_ground_truth(i);
        [numRows,numCols,numSlices] = size(data);
        
        for slice=1:numSlices
           mri_slice = data(:,:,slice);
           tumor_idx = find(mri_slice);
           reg_cell_idx = setdiff(1:numRows*numCols, tumor_idx);
           mri_slice(reg_cell_idx) = 1;
           mri_slice(tumor_idx) = 0;
           data(:,:,slice) = mri_slice;
        end
        
        %Save as nii
        saving_path = '/Users/pengzilun/Documents/mcgill/mcgill_homework/ecse_626/project/BRATS-2/Image_Data/HG/';
        saving_path = char(strcat(saving_path, sprintf("%04d",i)));
        saving_path = char(strcat(saving_path, '/tumor_mask.nii'));
        addpath('NIfTI_20140122')
        tumor_mask = make_nii(data);
        save_nii(tumor_mask, saving_path);
    end
end