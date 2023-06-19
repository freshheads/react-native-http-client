import { NativeModules, Platform } from 'react-native';

const LINKING_ERROR =
  `The package 'react-native-http-client' doesn't seem to be linked. Make sure: \n\n` +
  Platform.select({ ios: "- You have run 'pod install'\n", default: '' }) +
  '- You rebuilt the app after installing the package\n' +
  '- You are not using Expo Go\n';

const HttpClient = NativeModules.HttpClient
  ? NativeModules.HttpClient
  : (new Proxy(
      {},
      {
        get() {
          throw new Error(LINKING_ERROR);
        },
      }
    ) as NativeHttpClientApi) || undefined;

type Headers = { [headerName: string]: string };

type HttpGetResult = {
  statusCode: number;
  requestHeaders: Headers;
  responseHeaders: Headers;
  body: string;
};

type RequestOptions = {
  headers?: { [key: string]: string };
  params?: { [key: string]: string };
};

interface NativeHttpClientApi {
  get(url: string, optionsJson?: string): Promise<string>;
}

interface NativeHttpClientApiWrapper {
  get(url: string, options?: RequestOptions): Promise<HttpGetResult>;
}

export const client: NativeHttpClientApiWrapper = {
  get: async (url, options) => {
    const optionsJson = options ? JSON.stringify(options) : undefined;
    const output = await HttpClient.get(url, optionsJson);
    return JSON.parse(output);
  },
};
