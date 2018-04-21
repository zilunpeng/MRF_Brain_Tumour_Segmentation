%% Return linear indicies of voxels in the center of each slice of a MRI volume 
% Excluding top, bottom, left, right row
function [center_idx] = get_center_idx(numRows, numCols, numSlices)
    num_px_one_slice = numRows*numCols;
    num_px_tot = num_px_one_slice*numSlices;
    top_row_idx = 1:numRows:(num_px_one_slice-numRows+1);
    bottom_row_idx=numRows:numRows:num_px_one_slice;
    left_col_idx = 1:1:numRows;
    right_col_idx = num_px_one_slice-numRows+1:1:num_px_one_slice;
    center_idx = setdiff(1:num_px_one_slice, [top_row_idx, bottom_row_idx,left_col_idx,right_col_idx]);
    % Repeat this process for every slice
    num_center_idx = length(center_idx);
    center_idx = repmat(center_idx, 1, numSlices);
    offset_between_slices = 0:num_px_one_slice:(numSlices-1)*num_px_one_slice;
    offset_between_slices = repelem(offset_between_slices, num_center_idx);
    center_idx = center_idx + offset_between_slices;
    center_idx = center_idx(:,num_center_idx+1:end-num_center_idx);
end