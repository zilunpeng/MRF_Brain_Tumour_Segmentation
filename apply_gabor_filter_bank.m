function [flair_gabormag, t1_gabormag, t1c_gabormag, t2_gabormag] = apply_gabor_filter_bank(g, flair_data, t1_data, t1c_data, t2_data)
    flair_gabormag = imgaborfilt(flair_data,g);
    t1_gabormag = imgaborfilt(t1_data,g);
    t1c_gabormag = imgaborfilt(t1c_data,g);
    t2_gabormag = imgaborfilt(t2_data,g);
end