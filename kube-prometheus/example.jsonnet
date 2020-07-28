local addServiceMonitor = {
    _config+:: {
        namespace: 'monitoring',
        prometheus+:: {
            namespaces+: ['YOUR-NAMESPACE'],
        },
    },
    prometheus+:: {
        serviceMonitorMyNamespace: {
            apiVersion: 'monitoring.coreos.com/v1',
            kind: 'ServiceMonitor',
            metadata: {
                name: 'php-fpm-prom-exporter',
                namespace: 'YOUR-NAMESPACE',
            },
            spec: {
                jobLabel: 'php-fpm',
                endpoints: [
                    {
                        port: 'http-web',
                    },
                ],
                selector: {
                    matchLabels: {
                        app: 'php-fpm-prom-exporter',
                    },
                },
            },
        },
    },
};

local customGrafanaDashboards = {
    _config+:: {
        namespace: 'monitoring',
    },
    grafanaDashboards+:: {  //  monitoring-mixin compatibility
        'kubernetes-php-fpm.json': (import 'grafana-dashboards/kubernetes-php-fpm.json'),
    },
    grafana+:: {
        dashboards+:: {  // use this method to import your dashboards to Grafana
            'kubernetes-php-fpm.json': (import 'grafana-dashboards/kubernetes-php-fpm.json'),
        },
    },
};

local kp =
    (import 'kube-prometheus/kube-prometheus.libsonnet') +
    addServiceMonitor +
    customGrafanaDashboards

{ ['00namespace-' + name + '.json']: kp.kubePrometheus[name] for name in std.objectFields(kp.kubePrometheus) } +
{ ['0prometheus-operator-' + name + '.json']: kp.prometheusOperator[name] for name in std.objectFields(kp.prometheusOperator) } +
{ ['node-exporter-' + name + '.json']: kp.nodeExporter[name] for name in std.objectFields(kp.nodeExporter) } +
{ ['kube-state-metrics-' + name + '.json']: kp.kubeStateMetrics[name] for name in std.objectFields(kp.kubeStateMetrics) } +
{ ['alertmanager-' + name + '.json']: kp.alertmanager[name] for name in std.objectFields(kp.alertmanager) } +
{ ['prometheus-' + name + '.json']: kp.prometheus[name] for name in std.objectFields(kp.prometheus) } +
{ ['prometheus-adapter-' + name + '.json']: kp.prometheusAdapter[name] for name in std.objectFields(kp.prometheusAdapter) } +
{ ['grafana-' + name + '.json']: kp.grafana[name] for name in std.objectFields(kp.grafana) }