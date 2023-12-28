# Generated by the gRPC Python protocol compiler plugin. DO NOT EDIT!
"""Client and server classes corresponding to protobuf-defined services."""
import grpc

from google.protobuf import empty_pb2 as google_dot_protobuf_dot_empty__pb2
import policy_pb2 as policy__pb2


class ProbeServiceStub(object):
    """Missing associated documentation comment in .proto file."""

    def __init__(self, channel):
        """Constructor.

        Args:
            channel: A grpc.Channel.
        """
        self.getProbeData = channel.unary_unary(
                '/policy.ProbeService/getProbeData',
                request_serializer=google_dot_protobuf_dot_empty__pb2.Empty.SerializeToString,
                response_deserializer=policy__pb2.ProbeResponse.FromString,
                )


class ProbeServiceServicer(object):
    """Missing associated documentation comment in .proto file."""

    def getProbeData(self, request, context):
        """Missing associated documentation comment in .proto file."""
        context.set_code(grpc.StatusCode.UNIMPLEMENTED)
        context.set_details('Method not implemented!')
        raise NotImplementedError('Method not implemented!')


def add_ProbeServiceServicer_to_server(servicer, server):
    rpc_method_handlers = {
            'getProbeData': grpc.unary_unary_rpc_method_handler(
                    servicer.getProbeData,
                    request_deserializer=google_dot_protobuf_dot_empty__pb2.Empty.FromString,
                    response_serializer=policy__pb2.ProbeResponse.SerializeToString,
            ),
    }
    generic_handler = grpc.method_handlers_generic_handler(
            'policy.ProbeService', rpc_method_handlers)
    server.add_generic_rpc_handlers((generic_handler,))


 # This class is part of an EXPERIMENTAL API.
class ProbeService(object):
    """Missing associated documentation comment in .proto file."""

    @staticmethod
    def getProbeData(request,
            target,
            options=(),
            channel_credentials=None,
            call_credentials=None,
            insecure=False,
            compression=None,
            wait_for_ready=None,
            timeout=None,
            metadata=None):
        return grpc.experimental.unary_unary(request, target, '/policy.ProbeService/getProbeData',
            google_dot_protobuf_dot_empty__pb2.Empty.SerializeToString,
            policy__pb2.ProbeResponse.FromString,
            options, channel_credentials,
            insecure, call_credentials, compression, wait_for_ready, timeout, metadata)


class PolicyServiceStub(object):
    """Missing associated documentation comment in .proto file."""

    def __init__(self, channel):
        """Constructor.

        Args:
            channel: A grpc.Channel.
        """
        self.containerPolicy = channel.unary_unary(
                '/policy.PolicyService/containerPolicy',
                request_serializer=policy__pb2.policy.SerializeToString,
                response_deserializer=policy__pb2.response.FromString,
                )
        self.hostPolicy = channel.unary_unary(
                '/policy.PolicyService/hostPolicy',
                request_serializer=policy__pb2.policy.SerializeToString,
                response_deserializer=policy__pb2.response.FromString,
                )


class PolicyServiceServicer(object):
    """Missing associated documentation comment in .proto file."""

    def containerPolicy(self, request, context):
        """Missing associated documentation comment in .proto file."""
        context.set_code(grpc.StatusCode.UNIMPLEMENTED)
        context.set_details('Method not implemented!')
        raise NotImplementedError('Method not implemented!')

    def hostPolicy(self, request, context):
        """Missing associated documentation comment in .proto file."""
        context.set_code(grpc.StatusCode.UNIMPLEMENTED)
        context.set_details('Method not implemented!')
        raise NotImplementedError('Method not implemented!')


def add_PolicyServiceServicer_to_server(servicer, server):
    rpc_method_handlers = {
            'containerPolicy': grpc.unary_unary_rpc_method_handler(
                    servicer.containerPolicy,
                    request_deserializer=policy__pb2.policy.FromString,
                    response_serializer=policy__pb2.response.SerializeToString,
            ),
            'hostPolicy': grpc.unary_unary_rpc_method_handler(
                    servicer.hostPolicy,
                    request_deserializer=policy__pb2.policy.FromString,
                    response_serializer=policy__pb2.response.SerializeToString,
            ),
    }
    generic_handler = grpc.method_handlers_generic_handler(
            'policy.PolicyService', rpc_method_handlers)
    server.add_generic_rpc_handlers((generic_handler,))


 # This class is part of an EXPERIMENTAL API.
class PolicyService(object):
    """Missing associated documentation comment in .proto file."""

    @staticmethod
    def containerPolicy(request,
            target,
            options=(),
            channel_credentials=None,
            call_credentials=None,
            insecure=False,
            compression=None,
            wait_for_ready=None,
            timeout=None,
            metadata=None):
        return grpc.experimental.unary_unary(request, target, '/policy.PolicyService/containerPolicy',
            policy__pb2.policy.SerializeToString,
            policy__pb2.response.FromString,
            options, channel_credentials,
            insecure, call_credentials, compression, wait_for_ready, timeout, metadata)

    @staticmethod
    def hostPolicy(request,
            target,
            options=(),
            channel_credentials=None,
            call_credentials=None,
            insecure=False,
            compression=None,
            wait_for_ready=None,
            timeout=None,
            metadata=None):
        return grpc.experimental.unary_unary(request, target, '/policy.PolicyService/hostPolicy',
            policy__pb2.policy.SerializeToString,
            policy__pb2.response.FromString,
            options, channel_credentials,
            insecure, call_credentials, compression, wait_for_ready, timeout, metadata)


class PolicyStreamServiceStub(object):
    """Missing associated documentation comment in .proto file."""

    def __init__(self, channel):
        """Constructor.

        Args:
            channel: A grpc.Channel.
        """
        self.HealthCheck = channel.unary_unary(
                '/policy.PolicyStreamService/HealthCheck',
                request_serializer=policy__pb2.HealthCheckReq.SerializeToString,
                response_deserializer=policy__pb2.HealthCheckReply.FromString,
                )
        self.containerPolicy = channel.stream_stream(
                '/policy.PolicyStreamService/containerPolicy',
                request_serializer=policy__pb2.response.SerializeToString,
                response_deserializer=policy__pb2.policy.FromString,
                )
        self.hostPolicy = channel.stream_stream(
                '/policy.PolicyStreamService/hostPolicy',
                request_serializer=policy__pb2.response.SerializeToString,
                response_deserializer=policy__pb2.policy.FromString,
                )


class PolicyStreamServiceServicer(object):
    """Missing associated documentation comment in .proto file."""

    def HealthCheck(self, request, context):
        """Missing associated documentation comment in .proto file."""
        context.set_code(grpc.StatusCode.UNIMPLEMENTED)
        context.set_details('Method not implemented!')
        raise NotImplementedError('Method not implemented!')

    def containerPolicy(self, request_iterator, context):
        """Missing associated documentation comment in .proto file."""
        context.set_code(grpc.StatusCode.UNIMPLEMENTED)
        context.set_details('Method not implemented!')
        raise NotImplementedError('Method not implemented!')

    def hostPolicy(self, request_iterator, context):
        """Missing associated documentation comment in .proto file."""
        context.set_code(grpc.StatusCode.UNIMPLEMENTED)
        context.set_details('Method not implemented!')
        raise NotImplementedError('Method not implemented!')


def add_PolicyStreamServiceServicer_to_server(servicer, server):
    rpc_method_handlers = {
            'HealthCheck': grpc.unary_unary_rpc_method_handler(
                    servicer.HealthCheck,
                    request_deserializer=policy__pb2.HealthCheckReq.FromString,
                    response_serializer=policy__pb2.HealthCheckReply.SerializeToString,
            ),
            'containerPolicy': grpc.stream_stream_rpc_method_handler(
                    servicer.containerPolicy,
                    request_deserializer=policy__pb2.response.FromString,
                    response_serializer=policy__pb2.policy.SerializeToString,
            ),
            'hostPolicy': grpc.stream_stream_rpc_method_handler(
                    servicer.hostPolicy,
                    request_deserializer=policy__pb2.response.FromString,
                    response_serializer=policy__pb2.policy.SerializeToString,
            ),
    }
    generic_handler = grpc.method_handlers_generic_handler(
            'policy.PolicyStreamService', rpc_method_handlers)
    server.add_generic_rpc_handlers((generic_handler,))


 # This class is part of an EXPERIMENTAL API.
class PolicyStreamService(object):
    """Missing associated documentation comment in .proto file."""

    @staticmethod
    def HealthCheck(request,
            target,
            options=(),
            channel_credentials=None,
            call_credentials=None,
            insecure=False,
            compression=None,
            wait_for_ready=None,
            timeout=None,
            metadata=None):
        return grpc.experimental.unary_unary(request, target, '/policy.PolicyStreamService/HealthCheck',
            policy__pb2.HealthCheckReq.SerializeToString,
            policy__pb2.HealthCheckReply.FromString,
            options, channel_credentials,
            insecure, call_credentials, compression, wait_for_ready, timeout, metadata)

    @staticmethod
    def containerPolicy(request_iterator,
            target,
            options=(),
            channel_credentials=None,
            call_credentials=None,
            insecure=False,
            compression=None,
            wait_for_ready=None,
            timeout=None,
            metadata=None):
        return grpc.experimental.stream_stream(request_iterator, target, '/policy.PolicyStreamService/containerPolicy',
            policy__pb2.response.SerializeToString,
            policy__pb2.policy.FromString,
            options, channel_credentials,
            insecure, call_credentials, compression, wait_for_ready, timeout, metadata)

    @staticmethod
    def hostPolicy(request_iterator,
            target,
            options=(),
            channel_credentials=None,
            call_credentials=None,
            insecure=False,
            compression=None,
            wait_for_ready=None,
            timeout=None,
            metadata=None):
        return grpc.experimental.stream_stream(request_iterator, target, '/policy.PolicyStreamService/hostPolicy',
            policy__pb2.response.SerializeToString,
            policy__pb2.policy.FromString,
            options, channel_credentials,
            insecure, call_credentials, compression, wait_for_ready, timeout, metadata)