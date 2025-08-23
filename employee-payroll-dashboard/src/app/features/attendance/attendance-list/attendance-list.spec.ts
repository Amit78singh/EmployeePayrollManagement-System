import { ComponentFixture, TestBed } from '@angular/core/testing';

import { AttendanceList } from './attendance-list';

describe('AttendanceList', () => {
  let component: AttendanceList;
  let fixture: ComponentFixture<AttendanceList>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [AttendanceList]
    })
    .compileComponents();

    fixture = TestBed.createComponent(AttendanceList);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
