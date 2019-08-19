# tollwerk/gulp
Node.js, Gulp and a [Fractal pattern library](https://fractal.build/) with TYPO3 bridge & Tenon connector

The image makes use of these directories:

```bash
├── fractal
│   ├── build
│   └── components
└── project
    ├── docs
    └── public
```

* `fractal/build`: Configured as directory for static web export
* `fractal/components`: Configured as component directory
* `project/docs`: Configured as documentation directory
* `project/public`: Configured as directory for static assets

The image makes use of these environment variables:

* `FRACTAL_TITLE`: Title of the pattern library (defaults to "Unspecified")
* `FRACTAL_COMPONENTS_LABEL`: Label for the components group (defaults to "Patterns")
* `FRACTAL_PUBLIC_URL`: Public URL to the Fractal instance (needed for the Tenon plugin)
* `FRACTAL_TENON_API_KEY`: API key for [tenon.io](https://tenon.io) (enables the Tenon plugin)
