module FINGERPRINT;

export { type Info: record {}; }
redef record connection += { fp: FINGERPRINT::Info &optional; };

@load ./config
@load ./utils/common
@load ./utils/ssl-consts

@if (JA4_enabled)
  @load ./ja4
@endif

@if (JA4S_enabled)
  @load ./ja4s
@endif
