import * as React from 'react';

import { StyleSheet, View, Text, Button } from 'react-native';
import { client } from 'react-native-http-client';

export default function App() {
  const [result, setResult] = React.useState<string>();

  return (
    <View style={styles.container}>
      <View style={styles.box}>
        <Button
          title={'Get Request'}
          onPress={async () => {
            const output = await client.get(
              'https://jsonplaceholder.typicode.com/todos/2'
            );
            setResult(output.body);
          }}
        />
      </View>

      <Text>Result: {result}</Text>
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    alignItems: 'center',
    justifyContent: 'center',
  },
  box: {
    width: 150,
    height: 60,
    marginVertical: 20,
  },
});
