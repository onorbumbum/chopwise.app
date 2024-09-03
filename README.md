# Chopwise: Wood Cutting Optimizer

Chopwise is a Flutter web application designed to help woodworkers, DIY enthusiasts, and professionals optimize their wood cutting layouts. By efficiently planning cuts, Chopwise minimizes waste, saves time, and reduces costs associated with woodworking projects.

## Features

- **Input Board Dimensions**: Easily specify the length and width of your stock boards.
- **Define Cut Pieces**: Enter the dimensions and quantities of the pieces you need to cut.
- **Cutting Kerf Consideration**: Account for saw blade thickness in calculations.
- **Optimize Cut Layouts**: Automatically generate efficient cutting patterns.
- **Visual Representation**: See a clear, color-coded visualization of the optimized cuts.
- **Multiple Board Support**: Handle projects requiring multiple boards.
- **Remaining Material Calculation**: View the amount of unused material for each board.
- **Print Functionality**: Generate printer-friendly cut lists and visualizations.
- **Responsive Design**: Use on desktop or mobile devices with a consistent experience.

## How It Works

1. **Board Setup**: Enter the dimensions of your stock board(s) and the kerf (saw blade thickness).
2. **Cut List Creation**: Input the sizes and quantities of the pieces you need to cut.
3. **Optimization**: The app uses an algorithm to arrange the cuts efficiently on the board(s).
4. **Visualization**: View a color-coded layout of how to make the cuts on each board.
5. **Output**: See a summary of the cuts for each board, including remaining material.
6. **Print**: Generate a printer-friendly version of the cut list and layouts.

## Technical Details

- **Framework**: Built with Flutter for web
- **Language**: Dart
- **Optimization Algorithm**: Custom implementation for 2D bin packing
- **Responsive Design**: Adapts to various screen sizes for desktop and mobile use

## Getting Started

To run Chopwise locally:

1. Ensure you have Flutter installed and set up for web development.
2. Clone the repository:
   ```
   git clone https://github.com/yourusername/chopwise.app.git
   ```
3. Navigate to the project directory:
   ```
   cd chopwise.app
   ```
4. Get the dependencies:
   ```
   flutter pub get
   ```
5. Run the app:
   ```
   flutter run -d chrome
   ```

## Contributing

We welcome contributions to Chopwise! If you have suggestions for improvements or bug fixes, please:

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details.

## Acknowledgments

- Inspired by the needs of woodworkers and DIY enthusiasts
- Built with Flutter, an open-source UI software development kit created by Google

## Contact

Onur Uzunismail - onur@uzunu.com

---

Chopwise - Cut costs, not corners!
Courtesy of [Uzunu](https://www.uzunu.com)