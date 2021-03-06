var webpack = require('webpack')

module.exports = {
  entry: './src/polyinter.coffee',
  output: {
    path: __dirname,
    filename: 'polyinter.js'
  },
  module: {
    rules: [
      {
        test: /\.coffee$/,
        use: [ 'coffee-loader' ]
      }
    ]
  }
}
