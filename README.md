# AdGuard-Lists

The goal is to combine these great lists and make it as small as possible.
More regex and wildcard filters will be added to "AdGuard_DNS_Blocklist.txt" over time to make the list smaller
"whitelist.old" is obsolete but contains many commonly whitelisted items if you would like to use them.

- Duplicates Removed
- Filters that match regex and wildcard filters are removed
- Filters that are already in the list as a shorter filter are removed. Ex `||a.b.c.d` would be replaced if `||b.c.d` or `||c.d` exists
- Whitelisted items from original files are preserved with duplicates removed

Blocklist [url](https://raw.githubusercontent.com/dd900/AdGuard-Lists/master/blocklist.txt) 


Lists used can be found in "BlockLists.xml"