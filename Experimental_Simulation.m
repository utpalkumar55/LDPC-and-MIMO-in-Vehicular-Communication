clear;
clc;

%%%%%------------------------------1x1 MIMO-------------------------------%%%%%%
System_Parameter;
number_of_transmit_antenna = 1;
number_of_receive_antenna = 1;
equalizer_mode = 2;
System_Initialize;
fprintf('numTx: %d; numRx: %d; Doppler: %d; Equalizer: %d\n', number_of_transmit_antenna, ...
        number_of_receive_antenna, doppler_effect, equalizer_mode);

LDPC_and_MIMOinDSRC;

overall_throughput = ((number_of_bits_per_frame * (total_frame_count - total_error_frame_count)) / (1e-3 * total_frame_count))/1e6;
fprintf('Throughput (SM) 1x1 with %4.4f LDPC Code = %4.4f \n', coding_rate, overall_throughput);
fprintf('\n\n');

error_rate_1x1_ldpc = error_rate;
throughput_1x1_ldpc = throughput;
%%%%%------------------------------1x1 MIMO-------------------------------%%%%%%


%%%%%------------------------------2x2 MIMO-------------------------------%%%%%%
System_Parameter;
number_of_transmit_antenna = 2;
number_of_receive_antenna = 2;
equalizer_mode = 2;
System_Initialize;
fprintf('numTx: %d; numRx: %d; Doppler: %d; Equalizer: %d\n', number_of_transmit_antenna, ...
        number_of_receive_antenna, doppler_effect, equalizer_mode);

LDPC_and_MIMOinDSRC;

overall_throughput = ((number_of_bits_per_frame * (total_frame_count - total_error_frame_count)) / (1e-3 * total_frame_count))/1e6;
fprintf('Throughput (SM) 2x2 with %4.4f LDPC Code = %4.4f \n', coding_rate, overall_throughput);
fprintf('\n\n');

error_rate_2x2_ldpc = error_rate;
throughput_2x2_ldpc = throughput;
%%%%%------------------------------2x2 MIMO-------------------------------%%%%%%


%%%%%------------------------------4x4 MIMO-------------------------------%%%%%%
System_Parameter;
number_of_transmit_antenna = 4;
number_of_receive_antenna = 4;
equalizer_mode = 2;
System_Initialize;
fprintf('numTx: %d; numRx: %d; Doppler: %d; Equalizer: %d\n', number_of_transmit_antenna, ...
        number_of_receive_antenna, doppler_effect, equalizer_mode);

LDPC_and_MIMOinDSRC;

overall_throughput = ((number_of_bits_per_frame * (total_frame_count - total_error_frame_count)) / (1e-3 * total_frame_count))/1e6;
fprintf('Throughput (SM) 4x4 with %4.4f LDPC Code = %4.4f \n', coding_rate, overall_throughput);
fprintf('\n\n');

error_rate_4x4_ldpc = error_rate;
throughput_4x4_ldpc = throughput;
%%%%%------------------------------4x4 MIMO-------------------------------%%%%%%


%%%%%%---------------------------Displaying Bit Error Rate---------------------------%%%%%%
figure('Name','Bit Error Rate','NumberTitle','off','Position', ...
    [200, 80, 900, 550]); % Naming the figure and setting the position
subplot(1,1,1);
semilogy(EbNo, error_rate_1x1_ldpc, 'ko-', 'LineWidth', 2);
hold on;
semilogy(EbNo, error_rate_2x2_ldpc, 'ro-', 'LineWidth', 2);
hold on;
semilogy(EbNo, error_rate_4x4_ldpc, 'bo-', 'LineWidth', 2);
hold off;
grid on;
xlabel('SNR (dB)');
ylabel('BER');
legend('Conventional DSRC', 'DSRC with 2x2 MIMO', 'DSRC with 4x4 MIMO');
%%%%%%---------------------------Displaying Bit Error Rate---------------------------%%%%%%


%%%%%%-----------------------------Displaying Throughput------------------------------%%%%%%
figure('Name','Throughput','NumberTitle','off','Position', ...
    [200, 80, 900, 550]); % Naming the figure and setting the position
subplot(1,1,1);
semilogy(EbNo, throughput_1x1_ldpc, 'ko-', 'LineWidth', 2);
hold on;
semilogy(EbNo, throughput_2x2_ldpc, 'ro-', 'LineWidth', 2);
hold on;
semilogy(EbNo, throughput_4x4_ldpc, 'bo-', 'LineWidth', 2);
hold off;
grid on;
xlabel('SNR (dB)');
ylabel('Throughput');
legend('Conventional DSRC', 'DSRC with 2x2 MIMO', 'DSRC with 4x4 MIMO', 'Location','southeast');
%%%%%%-----------------------------Displaying Throughput------------------------------%%%%%%