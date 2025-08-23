import { ComponentFixture, TestBed } from '@angular/core/testing';

import { MarkAttendance } from './mark-attendance';

describe('MarkAttendance', () => {
  let component: MarkAttendance;
  let fixture: ComponentFixture<MarkAttendance>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [MarkAttendance]
    })
    .compileComponents();

    fixture = TestBed.createComponent(MarkAttendance);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
