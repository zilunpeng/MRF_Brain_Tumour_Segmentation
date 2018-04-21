function [center_vx_intensity, neighbor_id] = get_center_ngbr_vx_intensity(intensity_mat, center_idx, numRows, numCols)
    ngbr_vx_idx = get_neighbor_vx_idx(center_idx, numRows, numCols);
    center_vx_intensity = intensity_mat(:,center_idx);
    [up_id, down_id, left_id, right_id, ul_id, ur_id, dl_id, dr_id, slice_above_id, slice_below_id] = get_ngbr_intensity_diff(center_vx_intensity, intensity_mat, ngbr_vx_idx);

    neighbor_id{1} = up_id;
    neighbor_id{2} = down_id;
    neighbor_id{3} = left_id;
    neighbor_id{4} = right_id;
    neighbor_id{5} = ul_id;
    neighbor_id{6} = ur_id;
    neighbor_id{7} = dl_id;
    neighbor_id{8} = dr_id;
    neighbor_id{9} = slice_above_id;
    neighbor_id{10} = slice_below_id;
end