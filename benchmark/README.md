## Benchmarking & Performance

Timber was designed with an obsessive focus on performance and resource usage. In the `/benchmark` folder you'll find benchmarking tests.

The following results were run on a bare metal server in order to achieve consistent and repeatable results.

```console
+---------------------------+------------+-----------------+------------------+
|    Timber benchmarking. 10 requests per test. Times are "real" CPU time.    |
+---------------------------+------------+-----------------+------------------+
|                           | Total      | Per request avg | Per request diff |
+---------------------------+------------+-----------------+------------------+
| Control                   | 0.00568414 | 0.00056841      |                  |
| Timber probes only        | 0.00673819 | 0.00067382      | 0.0001054        |
| Timber probes and logging | 0.00912786 | 0.00091279      | 0.00023897       |
+---------------------------+------------+-----------------+------------------+
```

1. `Control` - This is vanilla rails app without Timber installed.
2. `Timber probels only` - The same rails app but with the `Timber::Probes` installed, isolating probes performance.
3. `Timber probes and logging` - Testing the full Timber library, probes and adding context to each log line.

The benchmark can be run yourself via:

```console
$ appraisal ruby benchmark/rails_request.rb
```