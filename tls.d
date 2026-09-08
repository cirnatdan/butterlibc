/*
 * Stub TLS implementation for butterlibc
 * This allows linking with -nostdlib by providing __tls_get_addr
 */

version (Posix):

extern (C):

/// Stub implementation of __tls_get_addr for glibc compatibility
/// In a real implementation, this would access thread-local storage
void* __tls_get_addr()
{
    return null;
}
