module.exports = {
  title: "Oskitone Scout Assembly Guide",
  url: "https://oskitone.github.io",
  baseUrl: "/scout/",
  onBrokenLinks: "throw",
  onBrokenMarkdownLinks: "warn",
  favicon: "img/favicon.ico",
  organizationName: "oskitone", // Usually your GitHub org/user name.
  projectName: "scout", // Usually your repo name.
  themeConfig: {
    navbar: {
      title: "Oskitone Scout Assembly Guide"
    },
    footer: {
      style: "dark",
      copyright: `Copyright © ${new Date().getFullYear()} Oskitone. Built with Docusaurus.`
    }
  },
  presets: [
    [
      "@docusaurus/preset-classic",
      {
        docs: {
          path: "./docs",
          routeBasePath: "/",
          sidebarPath: require.resolve("./sidebars.js")
        },
        theme: {
          customCss: require.resolve("./src/css/custom.css")
        }
      }
    ]
  ]
};
