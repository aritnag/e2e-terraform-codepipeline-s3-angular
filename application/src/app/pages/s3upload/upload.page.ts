import { Component, OnInit } from '@angular/core';
import { UploadFileService } from './upload.service';
import { Router } from '@angular/router';

@Component({
  selector: 'app-form-upload',
  templateUrl: './upload.page.html',
  styleUrls: ['./upload.scss']
})
export class UploadS3Object implements OnInit {
 
  selectedFiles!: FileList;
 
  constructor(private uploadService: UploadFileService,private router: Router) { }
 
  ngOnInit() {
  }
 
  upload() {
    const file = this.selectedFiles.item(0);
    this.uploadService.uploadfile(file);
    this.router.navigateByUrl("/objectuploaded")

  }
 
  selectFile(event:any) {
    this.selectedFiles = event.target.files;
  }
}