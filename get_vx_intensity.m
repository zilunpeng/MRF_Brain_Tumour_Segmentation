%% Return intensity value as 4*N matrix
%% Return intensity differences. There are 8: up, down, left, right, up_left, up_right, down_left, down_right
%% Return linear indicies of center voxels
function [intensity_mat, sum_intensity, numRows, numCols, numSlices] = get_vx_intensity(img_no)    
    [flair_data, t1_data, t1c_data, t2_data] = get_MRI_vols(img_no);
    [numRows,numCols,numSlices] = size(flair_data);
    total_vx = numRows*numCols*numSlices;

    sum_intensity = flair_data + t1_data + t1c_data + t2_data;
    flair_data = reshape(flair_data, [1,total_vx]);
    t1_data = reshape(t1_data, [1,total_vx]);
    t1c_data = reshape(t1c_data, [1,total_vx]);
    t2_data = reshape(t2_data, [1,total_vx]);
    intensity_mat = [flair_data; t1_data; t1c_data; t2_data];
    intensity_mat = double(intensity_mat);
end