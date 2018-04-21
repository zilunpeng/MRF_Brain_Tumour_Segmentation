function  cls_assignment = initialize_ICM(numClasses, intensity_given_cls_mean, intensity_given_cls_cov, center_vx_intensities, gab_bayes_prior)
    prob_igc = zeros(numClasses, size(gab_bayes_prior,2));
    
    for c=1:numClasses
        prob = mvnpdf(center_vx_intensities', intensity_given_cls_mean(c,:), intensity_given_cls_cov(:,:,c));
        prob_igc(c,:) = prob';
    end
    
    %prob_igc = prob_igc./sum(prob_igc);
    prob_igc = log(prob_igc) + log(gab_bayes_prior);
    [~, cls_assignment] = max(prob_igc);
    
end