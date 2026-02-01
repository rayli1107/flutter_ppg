import 'dart:math';

import 'complex_numbers.dart';

class FFT {
    static double calculateHeartRate(
        List<double> data,
        double fps) {
        // Preprocess: bandpass filter and normalize
        final signal = _bandpassFilter(data, fps);

        final fft = _computeFFT(signal);
        final n = fft.length;  // Use padded FFT length for frequency calculation
    
        // Find dominant frequency in valid range (0.7-4 Hz)
        double maxPower = 0.0;
        double dominantFreq = 0.0;
    
        for (int i = 0; i < n ~/ 2; i++) {
            final freq = i * fps / n;
      
            if (freq >= 0.7 && freq <= 4.0) {
                final power = fft[i].abs();
                if (power > maxPower) {
                    maxPower = power;
                    dominantFreq = freq;
                }
            }
        }
    
        // Convert Hz to BPM
        return dominantFreq * 60.0;
    }

    /// Bandpass filter (0.7-4 Hz = 42-240 BPM range)
    static List<double> _bandpassFilter(List<double> signal, double fps) {
        // Simple moving average for detrending
        final detrended = _detrend(signal);

        // Apply butterworth-style bandpass filter
        final lowCutoff = 0.7; // Hz (42 BPM)
        final highCutoff = 4.0; // Hz (240 BPM)

        return _simpleFilter(detrended, fps, lowCutoff, highCutoff);
    }

    /// Remove DC component and linear trend
    static List<double> _detrend(List<double> signal) {
        final mean = signal.reduce((a, b) => a + b) / signal.length;
        return signal.map((v) => v - mean).toList();
    }

    /// Simple bandpass filter implementation
    static List<double> _simpleFilter(
        List<double> signal,
        double fps,
        double lowCutoff,
        double highCutoff) {
        // High-pass filter (remove low frequencies)
        var filtered = _highPassFilter(signal, fps, lowCutoff);
    
        // Low-pass filter (remove high frequencies)
        filtered = _lowPassFilter(filtered, fps, highCutoff);
    
        return filtered;
    }

    /// Simple high-pass filter
    static List<double> _highPassFilter(
        List<double> signal,
        double fps,
        double cutoff) {
        final rc = 1.0 / (2.0 * pi * cutoff);
        final dt = 1.0 / fps;
        final alpha = rc / (rc + dt);
    
        final filtered = List<double>.filled(signal.length, 0.0);
        filtered[0] = signal[0];
    
        for (int i = 1; i < signal.length; i++) {
            filtered[i] = alpha * (filtered[i - 1] + signal[i] - signal[i - 1]);
        }
    
        return filtered;
    }

    /// Simple low-pass filter (moving average)
    static List<double> _lowPassFilter(
        List<double> signal,
        double fps,
        double cutoff) {
        final windowSize = (fps / cutoff).round();
        final filtered = <double>[];
    
        for (int i = 0; i < signal.length; i++) {
            final start = max(0, i - windowSize ~/ 2);
            final end = min(signal.length, i + windowSize ~/ 2 + 1);
            final sum = signal.sublist(start, end).reduce((a, b) => a + b);
            filtered.add(sum / (end - start));
        }
    
        return filtered;
    }

    /// Simple FFT implementation using Cooley-Tukey algorithm
    static List<ComplexNumber> _computeFFT(List<double> signal) {
        final n = signal.length;
    
        // Pad to next power of 2 for efficiency
        final paddedN = _nextPowerOf2(n);
        final padded = List<double>.from(signal);
        padded.addAll(List<double>.filled(paddedN - n, 0.0));
    
        // Convert to complex numbers
        final complex = padded.map((v) => ComplexNumber(v, 0.0)).toList();
    
        return _fftRecursive(complex);
    }

    /// Recursive FFT
    static List<ComplexNumber> _fftRecursive(List<ComplexNumber> x) {
        final n = x.length;
    
        if (n <= 1) return x;
    
        // Divide
        final even = <ComplexNumber>[];
        final odd = <ComplexNumber>[];
        for (int i = 0; i < n; i++) {
            if (i % 2 == 0) {
                even.add(x[i]);
            } else {
                odd.add(x[i]);
            }
        }
    
        // Conquer
        final fftEven = _fftRecursive(even);
        final fftOdd = _fftRecursive(odd);
    
        // Combine
        final result = List<ComplexNumber>.filled(n, ComplexNumber(0, 0));
        for (int k = 0; k < n ~/ 2; k++) {
            final t = ComplexNumber.exp(-2 * pi * k / n) * fftOdd[k];
            result[k] = fftEven[k] + t;
            result[k + n ~/ 2] = fftEven[k] - t;
        }
    
        return result;
    }

    /// Find next power of 2
    static int _nextPowerOf2(int n) {
        return pow(2, (log(n) / log(2)).ceil()).toInt();
    }
}