function [moyenne,variance] = estimation_loi_normale(echantillon)
echantillon = double(echantillon(:));

moyenne = mean(echantillon);
variance = mean((echantillon - moyenne).^2);