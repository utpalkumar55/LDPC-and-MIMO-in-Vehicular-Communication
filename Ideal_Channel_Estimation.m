function channel_estimation_matrix = Ideal_Channel_Estimation(channel_estimation_parameter)

    %%% Initializing FFT object 
    persistent dft; 
    if isempty(dft) 
       dft = dsp.FFT('FFTImplementation','FFTW'); 
    end
    %%% Initializing FFT object 

    %%% Getting the parameter values
    number_of_resource_block = channel_estimation_parameter.number_of_resource_block;
    number_of_data_subcarrier = channel_estimation_parameter.number_of_data_subcarrier;
    number_of_symbol = channel_estimation_parameter.number_of_symbol;
    number_of_transmit_antenna = channel_estimation_parameter.number_of_transmit_antenna;
    number_of_receive_antenna = channel_estimation_parameter.number_of_receive_antenna;
    fft_length = channel_estimation_parameter.fft_length;
    cyclic_prefix_length = channel_estimation_parameter.cyclic_prefix_length;
    path_delay = channel_estimation_parameter.path_delay;
    sampling_frequency = channel_estimation_parameter.sampling_frequency;
    channel_path_gain = channel_estimation_parameter.channel_path_gain;
    number_of_paths = channel_estimation_parameter.number_of_paths;
    data_subcarrier_indices = channel_estimation_parameter.data_subcarrier_indices;
    %%% Getting the parameter values

    slot_length = fft_length + cyclic_prefix_length; %% Defining the slot length

    sample_index = round(path_delay/(1/sampling_frequency)) + 1; %% Defining sample locations

    H = complex(zeros(number_of_resource_block * number_of_data_subcarrier, number_of_symbol, number_of_transmit_antenna, number_of_receive_antenna));
    for i= 1:number_of_transmit_antenna
        for j = 1:number_of_receive_antenna
            link_path_gain = channel_path_gain(:, :, i, j);
            %%% Splitting the path gain per OFDM symbol
            g = complex(zeros(number_of_symbol, number_of_paths));
            for m = 1:number_of_symbol
                index=(m-1)*slot_length + (1:slot_length);
                g(m, :) = mean(link_path_gain(index, :), 1);
            end
            hImp = complex(zeros(number_of_symbol, fft_length));
            hImp(:, sample_index) = g; %% Setting path gains at sample locations

            %%% FFT processing
            h = dft(hImp.');
            h2=fftshift(h,1);
            %%% FFT processing

            sc=h2(data_subcarrier_indices,:); %% Extracting the channel estimation values according to data subcarrier indices
            H(:,:,i,j) = sc;
        end
    end

    %%% Putting the channel estimation values in channel estimation matrix
    channel_estimation_matrix=complex(zeros(number_of_resource_block * number_of_data_subcarrier * number_of_symbol, number_of_transmit_antenna, number_of_receive_antenna));
    for n=1:number_of_receive_antenna
        for m=1:number_of_transmit_antenna
            tmp=H(:,:,m,n);
            tmp = reshape(tmp, number_of_resource_block * number_of_data_subcarrier * number_of_symbol, 1);
            channel_estimation_matrix(:,m,n)=tmp;
        end
    end
    %%% Putting the channel estimation values in channel estimation matrix

end