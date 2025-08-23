import { TestBed } from '@angular/core/testing';

import { Leave } from './leave';

describe('Leave', () => {
  let service: Leave;

  beforeEach(() => {
    TestBed.configureTestingModule({});
    service = TestBed.inject(Leave);
  });

  it('should be created', () => {
    expect(service).toBeTruthy();
  });
});
