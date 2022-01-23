error_rate = zeros(1, length(EbNo)); %% Declaring variable to store BER for each SNR value
throughput = zeros(1, length(EbNo)); %% Declaring variable to store cummulative Throughput for each SNR value

total_frame_count = 0; %% Declaring variable to count total number of transferred frames
total_error_frame_count = 0; %% Declaring variable to count total number of transferred frame which contains error

for ebno = 1:length(EbNo) %% Running loop to run simulation for each SNR value
    
    snr_dB = EbNo(ebno); %% Getting one SNR value in each iteration

    error_rate_calculator = comm.ErrorRate; %%% Declaring object to calculate BER for each SNR value
    
    number_of_bits = 0;

    while number_of_bits < maximum_number_of_bits %%% Running loop to process one frame in each iteration

        raw_data = logical(randi([0 1], number_of_bits_per_frame, 1)); %% Generating random data bits

        crc_coded_data = step(crc_24_generator, raw_data); %% Adding CRC bits for error checking
        
        ldpc_extra_bits = ldpc_num_bits - length(crc_coded_data);
        
        ldpc_data = [crc_coded_data; logical(randi([0 1], ldpc_extra_bits, 1))];
        
        ldpc_encoded_data = ldpc_encoder(ldpc_data);

        modulated_data = modulator(ldpc_encoded_data); %% Modulating the encoded data bits
        
        modulated_data_length = length(modulated_data);
        block_length = number_of_resource_block * number_of_data_subcarrier * number_of_symbol_per_subcarrier * number_of_transmit_antenna;
        number_of_turn = ceil(modulated_data_length / block_length);
        modulated_data = [modulated_data; complex(zeros(((block_length * number_of_turn) - modulated_data_length), 1))];
        
        reshaped_equalized_data = [];
        for turn = 1:number_of_turn
            reshaped_modulated_data = reshape(modulated_data((((turn - 1) * block_length) + 1):(turn * block_length), 1), number_of_resource_block * number_of_data_subcarrier, number_of_symbol_per_subcarrier, number_of_transmit_antenna);
            reshaped_modulated_data = [complex(zeros(margin, number_of_symbol_per_subcarrier, number_of_transmit_antenna)); reshaped_modulated_data; complex(zeros(margin, number_of_symbol_per_subcarrier, number_of_transmit_antenna))];

            %%% Generating pilot symbols
            for resource_block = 1:number_of_resource_block
                if resource_block == 1
                    pilot_data = Pilot_Generator(number_of_symbol_per_subcarrier,number_of_transmit_antenna);
                else
                    pilot_data = [pilot_data; Pilot_Generator(number_of_symbol_per_subcarrier,number_of_transmit_antenna)];
                end
            end
            %%% Generating pilot symbols

            ofdm_modulated_data = ofdm_mod(reshaped_modulated_data, pilot_data); %% OFDM modulation
        
            [faded_data, channel_path_gain] =  mimo_fading_channel(ofdm_modulated_data); %% Adding fading effect on the data symbols

            transmitted_data = faded_data;

            signal_power = 10*log10(var(transmitted_data)); %% Calculating signal power
            noise_variance = (10.^(0.1.*(signal_power - snr_dB))) * noise_factor; %% Calculating noise variance

            recevied_data =  awgn_channel(transmitted_data, noise_variance); %% Passing the transmitted data symbols through AWGN channel

            %%% OFDM Demodulation
            ofdm_demodulated_data = ofdm_demod(recevied_data);
            [len, ~, ~] = size(ofdm_demodulated_data);
            ofdm_demodulated_data = ofdm_demodulated_data((margin + 1):(len - margin), :, :);
            %%% OFDM Demodulation

            %%% Initializing channel estimation parameter
            channel_estimation_parameter.number_of_resource_block = number_of_resource_block;
            channel_estimation_parameter.number_of_data_subcarrier = number_of_data_subcarrier;
            channel_estimation_parameter.number_of_symbol = number_of_symbol_per_subcarrier;
            channel_estimation_parameter.number_of_transmit_antenna = number_of_transmit_antenna;
            channel_estimation_parameter.number_of_receive_antenna = number_of_receive_antenna;
            channel_estimation_parameter.fft_length = fft_length;
            channel_estimation_parameter.cyclic_prefix_length = cyclic_prefix_length;
            channel_estimation_parameter.path_delay = path_delay;
            channel_estimation_parameter.sampling_frequency = sampling_frequency;
            channel_estimation_parameter.channel_path_gain = channel_path_gain;
            channel_estimation_parameter.number_of_paths = number_of_paths;
            channel_estimation_parameter.data_subcarrier_indices = data_subcarrier_indices;
            %%% Initializing channel estimation parameter

            channel_estimation_matrix = Ideal_Channel_Estimation(channel_estimation_parameter); %% Getting channel estimation matrix

            %%% Preparing the ofdm demodulated data symbols for equalization purpose
            processed_ofdm_demodulated_data = complex(zeros(number_of_resource_block * number_of_data_subcarrier * number_of_symbol_per_subcarrier, number_of_receive_antenna));
            for i=1:number_of_receive_antenna
                tmp = ofdm_demodulated_data(:, :, i);
                tmp = reshape(tmp, number_of_resource_block * number_of_data_subcarrier * number_of_symbol_per_subcarrier, 1);
                processed_ofdm_demodulated_data(:, i) = tmp;
            end
            %%% Preparing the ofdm demodulated data symbols for equalization purpose

            
            equalized_data = MMSE_Equalize(processed_ofdm_demodulated_data, channel_estimation_matrix, noise_variance);
            
            reshaped_equalized_data = [reshaped_equalized_data; equalized_data(:)];
        end
        
        reshaped_equalized_data = reshaped_equalized_data(1:modulated_data_length, 1); %% Collapsing OFDM demodulated data symbols

        demodulated_data = demodulator_soft(reshaped_equalized_data); %% Demodulating 

        ldpc_decoded_data = ldpc_decoder(demodulated_data); %% Decoding the data bits using convolutional decoder

        ldpc_useful_data = ldpc_decoded_data(1:length(crc_coded_data), 1); %% Filtering the decoded data bits

        [crc_decoded_data, frame_error] = step(crc_24_detector, ldpc_useful_data); %% Detecting frame error using CRC detector

        %%% Counting error frames as well as total frames
        if frame_error == 1
            total_error_frame_count = total_error_frame_count + 1;
        end
        total_frame_count = total_frame_count + 1;
        %%% Counting error frames as well as total frames

        measured_error_rate = error_rate_calculator(raw_data, crc_decoded_data); %% Calculating error rate

        error_rate(ebno) = measured_error_rate(1); %% Storing BER for each SNR value
        
        number_of_bits = measured_error_rate(3); %% Counting number of bits transmitted per SNR value

    end
    
    throughput(ebno) = ((number_of_bits_per_frame * (total_frame_count - total_error_frame_count)) / (1e-3 * total_frame_count))/1e6; %% Calculating Throughput
    
end