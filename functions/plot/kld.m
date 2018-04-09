function [kld] = kld(field_pmf,model_pmf)
%KLD 
%   fieldpmf is the field data probability mass function (Reference Distribution) and Model_pmf is fitted model PMF. 
% if sum(field_pmf)~=1 || sum(model_pmf)~=1
%     error('SUM OF EACH INPUT SHOULD BE EQUAL TO 1')
% end
kld = (-sum(field_pmf.*log2(model_pmf+eps)) + sum(field_pmf.*log2(field_pmf+eps)));
end

