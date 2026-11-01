class_name DownloadEntry
extends Resource

@export var fileName : String = "Untitled"
@export var fileType : String = "txt"
@export var fileTypeLong : String = "Text Document"
@export var filesize_num : float = 1.0
@export var filesize_unit : globalParameters.filesize_unit = globalParameters.filesize_unit.KB
@export var websiteSource : String = "example.com"
## Seconds the fake download takes. 0 = estimate from size
@export var duration : float = 0.0
## What actually gets delivered
@export var payload : Resource
