function [mean, cov] = finalize_mean_cov(mean, cov, counter, num_features, num_cls)
    counter = repelem(counter, 1, num_features);
    mean = mean ./ counter;
    for i=1:size(mean,1)
        n = counter(i,1);
        cov(:,:,i) = (1/n)*cov(:,:,i) - mean(i,:)'*mean(i,:);
        if det(cov(:,:,i)) <= 1e-5
            cov(:,:,i) = eye(num_features);
        end
    end
end
