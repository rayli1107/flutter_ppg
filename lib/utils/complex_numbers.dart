import 'dart:math';

class ComplexNumber {
    final double real;
    final double imag;

    ComplexNumber(this.real, this.imag);

    ComplexNumber operator +(ComplexNumber other) {
        return ComplexNumber(real + other.real, imag + other.imag);
    }

    ComplexNumber operator -(ComplexNumber other) {
        return ComplexNumber(real - other.real, imag - other.imag);
    }

    ComplexNumber operator *(ComplexNumber other) {
        return ComplexNumber(
            real * other.real - imag * other.imag,
            real * other.imag + imag * other.real,
        );
    }

    static ComplexNumber exp(double theta) {
        return ComplexNumber(cos(theta), sin(theta));
    }

    double abs() {
        return sqrt(real * real + imag * imag);
    }
}
