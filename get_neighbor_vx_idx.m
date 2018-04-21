function ngbr_vx_idx = get_neighbor_vx_idx(center_idx, numRows, numCols)
    ngbr_vx_idx{1}  = get_above_idx(center_idx); %above_vx_idx
    ngbr_vx_idx{2}  = get_below_idx(center_idx); %below_vx_idx
    ngbr_vx_idx{3}  = get_left_idx(center_idx, numRows); %left_vx_idx
    ngbr_vx_idx{4}  = get_right_idx(center_idx, numRows); %right_vx_idx
    ngbr_vx_idx{5}  = get_top_left_idx(center_idx, numRows); %ul_vx_idx
    ngbr_vx_idx{6}  = get_top_right_idx(center_idx, numRows); %ur_vx_idx
    ngbr_vx_idx{7}  = get_bottom_left_idx(center_idx, numRows); %dl_vx_idx
    ngbr_vx_idx{8}  = get_bottom_right_idx(center_idx, numRows); %dr_vx_idx
    ngbr_vx_idx{9}  = get_slice_above_vx_idx(center_idx, numRows, numCols); %slice_above_vx_idx
    ngbr_vx_idx{10} = get_slice_below_vx_idx(center_idx, numRows, numCols); %slice_below_vx_idx
end

%% Return liner indicies of voxels above every center voxel
function [above_idx] = get_above_idx(center_idx)
    above_idx = center_idx - 1;
end

%% Return liner indicies of voxels below every center voxel
function [below_idx] = get_below_idx(center_idx)
    below_idx = center_idx + 1;
end

%% Return liner indicies of voxels to the left of every center voxel
function [left_idx] = get_left_idx(center_idx, numRows)
    left_idx = center_idx - numRows;
end

%% Return liner indicies of voxels to the right of every center voxel
function [right_idx] = get_right_idx(center_idx, numRows)
    right_idx = center_idx + numRows;
end

%% Return liner indicies of voxels to the top left of every center voxel
function [top_left_idx] = get_top_left_idx(center_idx, numRows)
    top_left_idx = center_idx - numRows - 1;
end

%% Return liner indicies of voxels to the top right of every center voxel
function [top_right_idx] = get_top_right_idx(center_idx, numRows)
    top_right_idx = center_idx + numRows - 1;
end

%% Return liner indicies of voxels to the bottom left of every center voxel
function [bottom_left_idx] = get_bottom_left_idx(center_idx, numRows)
    bottom_left_idx = center_idx - numRows + 1;
end

%% Return liner indicies of voxels to the bottom right of every center voxel
function [bottom_right_idx] = get_bottom_right_idx(center_idx, numRows)
    bottom_right_idx = center_idx + numRows + 1;
end

%% Return liner indicies of voxels in the slice above every center voxel
function [slice_above_vx_idx] = get_slice_above_vx_idx(center_idx, numRows, numCols)
    slice_above_vx_idx = center_idx - numRows*numCols;
end

%% Return liner indicies of voxels in the slice below every center voxel
function [slice_below_vx_idx] = get_slice_below_vx_idx(center_idx, numRows, numCols)
    slice_below_vx_idx = center_idx + numRows*numCols;
end