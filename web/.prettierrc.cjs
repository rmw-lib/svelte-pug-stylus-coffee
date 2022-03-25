// https://prettier.github.io/plugin-pug/guide/pug-specific-options.html
module.exports = {
  plugins: [require.resolve("@prettier/plugin-pug")],
  printWidth: 90,
  pugAttributeSeparator: "none",
  pugSortAttributes: "asc",
  pugEmptyAttributes: "none",
};
