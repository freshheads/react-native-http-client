# React-Native-Http-Client

A Native HTTP Client for React Native projects.

For iOS, it utilizes URLRequest and URLSession. For Android, it deploys OkHttp.

The rationale behind this package is to provide a straightforward HTTP client that functions seamlessly across both
platforms and is user-friendly. Our objective was to establish a connection with a webservice hosted on an embedded
device. However, we encountered a persistent 401 error. Interestingly, the connection was successful via Postman.

We experimented with Axios, Fetch, and XMLHttpRequest to no avail. Consequently, we decided to devise a native HTTP
client that would cater to both platforms and simultaneously ensure simplicity of use.

Currently, the package only supports GET requests. However, we intend to incorporate additional methods as per
requirements in the future.

## Installation

Install the package using npm:

```sh
npm install react-native-http-client --save
```

## Example

To run the example:

```sh
yarn

# Android app
yarn example android

# iOS app
yarn example ios
```

## Usage

Basic usage:

```js
import { client } from 'react-native-http-client';

const output = await client.get(
  'https://example.dev/'
);

console.log(output.body);
```

Usage with headers and parameters:

```js
import { client } from 'react-native-http-client';

const output = await client.get(
  'https://example.dev/',
  {
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    },
    params: {
      'param1': 'value1',
      'param2': 'value2',
    },
  }
);

console.log(output.body);
```

## Contributing

To learn how to contribute to the repository and the development workflow, please refer to
the [contributing guide](CONTRIBUTING.md).

## License

MIT License.

---

Crafted with care using [create-react-native-library](https://github.com/callstack/react-native-builder-bob).
