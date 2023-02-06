import { Component } from '@angular/core';
import { Router } from '@angular/router';

@Component({
  templateUrl: './objectuploaded.page.html',
  styleUrls: ['./objectuploaded.scss']
})
export class ObjectUploaded {

    constructor(private router: Router) { }

    goback() {
        this.router.navigateByUrl("/")
    
      }
}
