{ fetchurl, fetchgit, linkFarm, runCommand, gnutar }: rec {
  offline_cache = linkFarm "offline" packages;
  packages = [
    {
      name = "_vscode_l10n___l10n_0.0.10.tgz";
      path = fetchurl {
        name = "_vscode_l10n___l10n_0.0.10.tgz";
        url  = "https://registry.yarnpkg.com/@vscode/l10n/-/l10n-0.0.10.tgz";
        sha512 = "E1OCmDcDWa0Ya7vtSjp/XfHFGqYJfh+YPC1RkATU71fTac+j1JjCcB3qwSzmlKAighx2WxhLlfhS0RwAN++PFQ==";
      };
    }
    {
      name = "_vscode_l10n___l10n_0.0.11.tgz";
      path = fetchurl {
        name = "_vscode_l10n___l10n_0.0.11.tgz";
        url  = "https://registry.yarnpkg.com/@vscode/l10n/-/l10n-0.0.11.tgz";
        sha512 = "ukOMWnCg1tCvT7WnDfsUKQOFDQGsyR5tNgRpwmqi+5/vzU3ghdDXzvIM4IOPdSb3OeSsBNvmSL8nxIVOqi2WXA==";
      };
    }
    {
      name = "core_js___core_js_3.29.1.tgz";
      path = fetchurl {
        name = "core_js___core_js_3.29.1.tgz";
        url  = "https://registry.yarnpkg.com/core-js/-/core-js-3.29.1.tgz";
        sha512 = "+jwgnhg6cQxKYIIjGtAHq2nwUOolo9eoFZ4sHfUH09BLXBgxnH4gA0zEd+t+BO2cNB8idaBtZFcFTRjQJRJmAw==";
      };
    }
    {
      name = "jsonc_parser___jsonc_parser_3.2.0.tgz";
      path = fetchurl {
        name = "jsonc_parser___jsonc_parser_3.2.0.tgz";
        url  = "https://registry.yarnpkg.com/jsonc-parser/-/jsonc-parser-3.2.0.tgz";
        sha512 = "gfFQZrcTc8CnKXp6Y4/CBT3fTc0OVuDofpre4aEeEpSBPV5X5v4+Vmx+8snU7RLPrNHPKSgLxGo9YuQzz20o+w==";
      };
    }
    {
      name = "picomatch___picomatch_2.3.1.tgz";
      path = fetchurl {
        name = "picomatch___picomatch_2.3.1.tgz";
        url  = "https://registry.yarnpkg.com/picomatch/-/picomatch-2.3.1.tgz";
        sha512 = "JU3teHTNjmE2VCGFzuY8EXzCDVwEqB2a8fsIvwaStHhAWJEeVd1o1QD80CU6+ZdEXXSLbSsuLwJjkCBWqRQUVA==";
      };
    }
    {
      name = "regenerator_runtime___regenerator_runtime_0.13.11.tgz";
      path = fetchurl {
        name = "regenerator_runtime___regenerator_runtime_0.13.11.tgz";
        url  = "https://registry.yarnpkg.com/regenerator-runtime/-/regenerator-runtime-0.13.11.tgz";
        sha512 = "kY1AZVr2Ra+t+piVaJ4gxaFaReZVH40AKNo7UCX6W+dEwBo/2oZJzqfuN1qLq1oL45o56cPaTXELwrTh8Fpggg==";
      };
    }
    {
      name = "request_light___request_light_0.7.0.tgz";
      path = fetchurl {
        name = "request_light___request_light_0.7.0.tgz";
        url  = "https://registry.yarnpkg.com/request-light/-/request-light-0.7.0.tgz";
        sha512 = "lMbBMrDoxgsyO+yB3sDcrDuX85yYt7sS8BfQd11jtbW/z5ZWgLZRcEGLsLoYw7I0WSUGQBs8CC8ScIxkTX1+6Q==";
      };
    }
    {
      name = "typescript___typescript_4.9.5.tgz";
      path = fetchurl {
        name = "typescript___typescript_4.9.5.tgz";
        url  = "https://registry.yarnpkg.com/typescript/-/typescript-4.9.5.tgz";
        sha512 = "1FXk9E2Hm+QzZQ7z+McJiHL4NW1F2EzMu9Nq9i3zAaGqibafqYwCVU6WyWAuyQRRzOlxou8xZSyXLEN8oKj24g==";
      };
    }
    {
      name = "vscode_css_languageservice___vscode_css_languageservice_6.2.4.tgz";
      path = fetchurl {
        name = "vscode_css_languageservice___vscode_css_languageservice_6.2.4.tgz";
        url  = "https://registry.yarnpkg.com/vscode-css-languageservice/-/vscode-css-languageservice-6.2.4.tgz";
        sha512 = "9UG0s3Ss8rbaaPZL1AkGzdjrGY8F+P+Ne9snsrvD9gxltDGhsn8C2dQpqQewHrMW37OvlqJoI8sUU2AWDb+qNw==";
      };
    }
    {
      name = "vscode_html_languageservice___vscode_html_languageservice_5.0.4.tgz";
      path = fetchurl {
        name = "vscode_html_languageservice___vscode_html_languageservice_5.0.4.tgz";
        url  = "https://registry.yarnpkg.com/vscode-html-languageservice/-/vscode-html-languageservice-5.0.4.tgz";
        sha512 = "tvrySfpglu4B2rQgWGVO/IL+skvU7kBkQotRlxA7ocSyRXOZUd6GA13XHkxo8LPe07KWjeoBlN1aVGqdfTK4xA==";
      };
    }
    {
      name = "vscode_json_languageservice___vscode_json_languageservice_5.3.2.tgz";
      path = fetchurl {
        name = "vscode_json_languageservice___vscode_json_languageservice_5.3.2.tgz";
        url  = "https://registry.yarnpkg.com/vscode-json-languageservice/-/vscode-json-languageservice-5.3.2.tgz";
        sha512 = "5td6olfoNdtyxnNA4uocq7V9jdTJt63o9mGEntQb6cbD2HiObZW2XgbSj6nRaebWwBCiYdWpFklNjm6Wz6Xy1Q==";
      };
    }
    {
      name = "vscode_jsonrpc___vscode_jsonrpc_8.1.0.tgz";
      path = fetchurl {
        name = "vscode_jsonrpc___vscode_jsonrpc_8.1.0.tgz";
        url  = "https://registry.yarnpkg.com/vscode-jsonrpc/-/vscode-jsonrpc-8.1.0.tgz";
        sha512 = "6TDy/abTQk+zDGYazgbIPc+4JoXdwC8NHU9Pbn4UJP1fehUyZmM4RHp5IthX7A6L5KS30PRui+j+tbbMMMafdw==";
      };
    }
    {
      name = "vscode_langservers_extracted___vscode_langservers_extracted_4.6.0.tgz";
      path = fetchurl {
        name = "vscode_langservers_extracted___vscode_langservers_extracted_4.6.0.tgz";
        url  = "https://registry.yarnpkg.com/vscode-langservers-extracted/-/vscode-langservers-extracted-4.6.0.tgz";
        sha512 = "PoDv5KANylqypzkUZTHTuBT8OZfFxhMwNCQ2vXIG1d3ZB6BrE+z6AZ6aJULxz6ZxhIYeCz4GQKFOHqfBlh7XGw==";
      };
    }
    {
      name = "vscode_languageserver_protocol___vscode_languageserver_protocol_3.17.3.tgz";
      path = fetchurl {
        name = "vscode_languageserver_protocol___vscode_languageserver_protocol_3.17.3.tgz";
        url  = "https://registry.yarnpkg.com/vscode-languageserver-protocol/-/vscode-languageserver-protocol-3.17.3.tgz";
        sha512 = "924/h0AqsMtA5yK22GgMtCYiMdCOtWTSGgUOkgEDX+wk2b0x4sAfLiO4NxBxqbiVtz7K7/1/RgVrVI0NClZwqA==";
      };
    }
    {
      name = "vscode_languageserver_textdocument___vscode_languageserver_textdocument_1.0.8.tgz";
      path = fetchurl {
        name = "vscode_languageserver_textdocument___vscode_languageserver_textdocument_1.0.8.tgz";
        url  = "https://registry.yarnpkg.com/vscode-languageserver-textdocument/-/vscode-languageserver-textdocument-1.0.8.tgz";
        sha512 = "1bonkGqQs5/fxGT5UchTgjGVnfysL0O8v1AYMBjqTbWQTFn721zaPGDYFkOKtfDgFiSgXM3KwaG3FMGfW4Ed9Q==";
      };
    }
    {
      name = "vscode_languageserver_textdocument___vscode_languageserver_textdocument_1.0.9.tgz";
      path = fetchurl {
        name = "vscode_languageserver_textdocument___vscode_languageserver_textdocument_1.0.9.tgz";
        url  = "https://registry.yarnpkg.com/vscode-languageserver-textdocument/-/vscode-languageserver-textdocument-1.0.9.tgz";
        sha512 = "NPfHVGFW2/fQEWHspr8x3PXhRgtFbuDZdl7p6ifuN3M7nk2Yjf5POr/NfDBuAiQG88DehDyJ7nGOT+p+edEtbw==";
      };
    }
    {
      name = "vscode_languageserver_types___vscode_languageserver_types_3.17.3.tgz";
      path = fetchurl {
        name = "vscode_languageserver_types___vscode_languageserver_types_3.17.3.tgz";
        url  = "https://registry.yarnpkg.com/vscode-languageserver-types/-/vscode-languageserver-types-3.17.3.tgz";
        sha512 = "SYU4z1dL0PyIMd4Vj8YOqFvHu7Hz/enbWtpfnVbJHU4Nd1YNYx8u0ennumc6h48GQNeOLxmwySmnADouT/AuZA==";
      };
    }
    {
      name = "vscode_languageserver___vscode_languageserver_8.1.0.tgz";
      path = fetchurl {
        name = "vscode_languageserver___vscode_languageserver_8.1.0.tgz";
        url  = "https://registry.yarnpkg.com/vscode-languageserver/-/vscode-languageserver-8.1.0.tgz";
        sha512 = "eUt8f1z2N2IEUDBsKaNapkz7jl5QpskN2Y0G01T/ItMxBxw1fJwvtySGB9QMecatne8jFIWJGWI61dWjyTLQsw==";
      };
    }
    {
      name = "vscode_markdown_languageservice___vscode_markdown_languageservice_0.3.0.tgz";
      path = fetchurl {
        name = "vscode_markdown_languageservice___vscode_markdown_languageservice_0.3.0.tgz";
        url  = "https://registry.yarnpkg.com/vscode-markdown-languageservice/-/vscode-markdown-languageservice-0.3.0.tgz";
        sha512 = "+HGaZSsZGHbNdDyjfdkDws9a9oiqUsfnW5AtZQpgcxCavP5Gwom77S4XXzL/uEUUZ5u1K/0VTOhqha7qPcCW5w==";
      };
    }
    {
      name = "vscode_nls___vscode_nls_5.2.0.tgz";
      path = fetchurl {
        name = "vscode_nls___vscode_nls_5.2.0.tgz";
        url  = "https://registry.yarnpkg.com/vscode-nls/-/vscode-nls-5.2.0.tgz";
        sha512 = "RAaHx7B14ZU04EU31pT+rKz2/zSl7xMsfIZuo8pd+KZO6PXtQmpevpq3vxvWNcrGbdmhM/rr5Uw5Mz+NBfhVng==";
      };
    }
    {
      name = "vscode_uri___vscode_uri_3.0.7.tgz";
      path = fetchurl {
        name = "vscode_uri___vscode_uri_3.0.7.tgz";
        url  = "https://registry.yarnpkg.com/vscode-uri/-/vscode-uri-3.0.7.tgz";
        sha512 = "eOpPHogvorZRobNqJGhapa0JdwaxpjVvyBp0QIUMRMSf8ZAlqOdEquKuRmw9Qwu0qXtJIWqFtMkmvJjUZmMjVA==";
      };
    }
  ];
}
